from __future__ import annotations

import argparse
import csv
import os
import re
from pathlib import Path
from typing import Iterable


PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CSV_DIR = PROJECT_ROOT / "data" / "processed" / "clean_missing"
DEFAULT_SCHEMA_FILE = PROJECT_ROOT / "sql" / "Staging" / "staging_schema.sql"
STAGING_SCHEMA = "staging"


def snake_case(name: str) -> str:
    return re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", name).lower()


def quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def table_name_from_csv(csv_path: Path) -> str:
    raw_table = csv_path.name.removesuffix("_clean.csv")
    return "stg_" + snake_case(raw_table)


def read_csv_header(csv_path: Path) -> list[str]:
    with csv_path.open("r", encoding="utf-8-sig", newline="") as file:
        return next(csv.reader(file))


def parse_schema_tables(schema_sql: str) -> dict[str, list[str]]:
    pattern = re.compile(
        r"CREATE TABLE IF NOT EXISTS staging\.(stg_[a-z_]+) \((.*?)\);",
        re.IGNORECASE | re.DOTALL,
    )
    tables: dict[str, list[str]] = {}
    for match in pattern.finditer(schema_sql):
        table_name = match.group(1)
        body = match.group(2)
        columns: list[str] = []
        for line in body.splitlines():
            text = line.strip().rstrip(",")
            if not text:
                continue
            first_token = text.split()[0].strip('"').upper()
            if first_token in {"CONSTRAINT", "PRIMARY", "FOREIGN", "UNIQUE", "CHECK"}:
                continue
            columns.append(text.split()[0].strip('"'))
        tables[table_name] = columns
    return tables


def load_schema_sql(schema_file: Path, recreate: bool) -> str:
    schema_sql = schema_file.read_text(encoding="utf-8")
    if recreate:
        return f"DROP SCHEMA IF EXISTS {quote_ident(STAGING_SCHEMA)} CASCADE;\n" + schema_sql
    return schema_sql


def iter_clean_csv_files(csv_dir: Path) -> Iterable[Path]:
    return sorted(csv_dir.glob("*_clean.csv"))


def validate_csv_headers(csv_files: list[Path], schema_tables: dict[str, list[str]]) -> None:
    errors: list[str] = []
    for csv_path in csv_files:
        table_name = table_name_from_csv(csv_path)
        csv_columns = [snake_case(col) for col in read_csv_header(csv_path)]
        table_columns = schema_tables.get(table_name)
        if table_columns is None:
            errors.append(f"{csv_path.name}: missing staging table {STAGING_SCHEMA}.{table_name}")
            continue

        csv_not_in_table = [col for col in csv_columns if col not in table_columns]
        table_not_in_csv = [col for col in table_columns if col not in csv_columns]
        if csv_not_in_table or table_not_in_csv:
            details = [f"{csv_path.name} -> {STAGING_SCHEMA}.{table_name}"]
            if csv_not_in_table:
                details.append(f"CSV_NOT_IN_TABLE={csv_not_in_table}")
            if table_not_in_csv:
                details.append(f"TABLE_NOT_IN_CSV={table_not_in_csv}")
            errors.append("; ".join(details))

    if errors:
        joined = "\n- ".join(errors)
        raise RuntimeError(f"CSV headers do not match staging schema:\n- {joined}")


def copy_csv_to_table(cursor, csv_path: Path, table_name: str, columns: list[str]) -> int | None:
    qualified_table = f"{quote_ident(STAGING_SCHEMA)}.{quote_ident(table_name)}"
    column_sql = ", ".join(quote_ident(col) for col in columns)
    copy_sql = (
        f"COPY {qualified_table} ({column_sql}) "
        "FROM STDIN WITH (FORMAT CSV, HEADER TRUE, NULL '')"
    )
    with csv_path.open("r", encoding="utf-8-sig", newline="") as file:
        cursor.copy_expert(copy_sql, file)
    return cursor.rowcount if cursor.rowcount != -1 else None


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Load data/processed/clean_missing CSV files into PostgreSQL staging tables."
    )
    parser.add_argument("--host", default=os.getenv("PGHOST", "localhost"))
    parser.add_argument("--port", default=int(os.getenv("PGPORT", "5432")), type=int)
    parser.add_argument("--database", default=os.getenv("PGDATABASE", "Staging"))
    parser.add_argument("--user", default=os.getenv("PGUSER", "postgres"))
    parser.add_argument("--password", default=os.getenv("PGPASSWORD","1101"))
    parser.add_argument("--csv-dir", default=DEFAULT_CSV_DIR, type=Path)
    parser.add_argument("--schema-file", default=DEFAULT_SCHEMA_FILE, type=Path)
    parser.add_argument(
        "--recreate",
        action="store_true",
        help="Drop and recreate the staging schema before loading. Use this when table columns changed.",
    )
    parser.add_argument(
        "--append",
        action="store_true",
        help="Append data instead of truncating staging tables before load.",
    )
    parser.add_argument(
        "--check-only",
        action="store_true",
        help="Only validate CSV headers against staging_schema.sql; do not connect to PostgreSQL.",
    )
    return parser


def connect_postgres(args):
    try:
        import psycopg2
    except ImportError as exc:  # pragma: no cover - user-facing dependency check
        raise SystemExit(
            "Missing dependency: psycopg2. Install it with: pip install psycopg2-binary"
        ) from exc

    return psycopg2.connect(
        host=args.host,
        port=args.port,
        dbname=args.database,
        user=args.user,
        password=args.password,
    )


def main() -> None:
    args = build_parser().parse_args()

    csv_files = list(iter_clean_csv_files(args.csv_dir))
    if not csv_files:
        raise SystemExit(f"No *_clean.csv files found in {args.csv_dir}")

    schema_sql_text = args.schema_file.read_text(encoding="utf-8")
    schema_tables = parse_schema_tables(schema_sql_text)
    validate_csv_headers(csv_files, schema_tables)

    if args.check_only:
        print(f"OK: {len(csv_files)} CSV files match {len(schema_tables)} staging tables.")
        return

    if not args.password:
        raise SystemExit("Password is required. Pass --password or set PGPASSWORD.")

    connection = connect_postgres(args)
    try:
        with connection:
            with connection.cursor() as cursor:
                cursor.execute(load_schema_sql(args.schema_file, args.recreate))

                if not args.append:
                    table_sql = ", ".join(
                        f"{quote_ident(STAGING_SCHEMA)}.{quote_ident(table_name_from_csv(path))}"
                        for path in csv_files
                    )
                    cursor.execute(f"TRUNCATE TABLE {table_sql};")

                for csv_path in csv_files:
                    table_name = table_name_from_csv(csv_path)
                    columns = [snake_case(col) for col in read_csv_header(csv_path)]
                    copied_rows = copy_csv_to_table(cursor, csv_path, table_name, columns)
                    row_text = "unknown rows" if copied_rows is None else f"{copied_rows:,} rows"
                    print(f"Loaded {csv_path.name} -> {STAGING_SCHEMA}.{table_name}: {row_text}")
    finally:
        connection.close()


if __name__ == "__main__":
    main()
