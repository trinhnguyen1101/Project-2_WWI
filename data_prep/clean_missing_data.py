from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
OUTPUT_DIR = PROJECT_ROOT / "data" / "processed" / "clean_missing"
REPORT_DIR = PROJECT_ROOT / "data_prep" / "reports" / "clean_missing"


# Keep this cleaning layer aligned with the business scope confirmed for the DWH.
SCOPE_TABLE_GROUPS = [
    {
        "category": "Dia ly",
        "tables": [
            "Application_Countries",
            "Application_StateProvinces",
            "Application_Cities",
        ],
    },
    {
        "category": "Khach hang",
        "tables": [
            "Sales_Customers",
            "Sales_CustomerCategories",
            "Sales_BuyingGroups",
        ],
    },
    {
        "category": "San pham",
        "tables": [
            "Warehouse_StockItems",
            "Warehouse_Colors",
            "Warehouse_PackageTypes",
            "Warehouse_StockGroups",
            "Warehouse_StockItemStockGroups",
        ],
    },
    {
        "category": "Nha cung cap",
        "tables": [
            "Purchasing_Suppliers",
            "Purchasing_SupplierCategories",
        ],
    },
    {
        "category": "Nhan su",
        "tables": [
            "Application_People",
        ],
    },
    {
        "category": "Giao hang thanh toan giao dich",
        "tables": [
            "Application_DeliveryMethods",
            "Application_PaymentMethods",
            "Application_TransactionTypes",
        ],
    },
    {
        "category": "Ban hang",
        "tables": [
            "Sales_Invoices",
            "Sales_InvoiceLines",
        ],
    },
    {
        "category": "Fulfillment don hang",
        "tables": [
            "Sales_Orders",
            "Sales_OrderLines",
        ],
    },
    {
        "category": "Cong no khach hang",
        "tables": [
            "Sales_CustomerTransactions",
        ],
    },
]

DWH_SCOPE_TABLES = [table for group in SCOPE_TABLE_GROUPS for table in group["tables"]]
TABLE_CATEGORY = {
    table: group["category"]
    for group in SCOPE_TABLE_GROUPS
    for table in group["tables"]
}


DROP_COLUMNS = {
    "Application_People": [
        "Photo",
        "CustomFields",
        "OtherLanguages",
        "HashedPassword",
        "UserPreferences",
    ],
    "Sales_Customers": [
        "DeliveryRun",
        "RunPosition",
    ],
    "Sales_Invoices": [
        "Comments",
        "InternalComments",
        "CreditNoteReason",
        "DeliveryRun",
        "RunPosition",
    ],
    "Sales_Orders": [
        "Comments",
        "DeliveryInstructions",
        "InternalComments",
    ],
    "Purchasing_Suppliers": [
        "InternalComments",
        "DeliveryLocation",
    ],
    "Warehouse_StockItems": [
        "Photo",
        "InternalComments",
        "MarketingComments",
        "Barcode",
        "SearchDetails",
    ],
}


MISSING_RULES = [
    {
        "table_name": "Sales_CustomerTransactions",
        "column_name": "PaymentMethodID",
        "action": "keep_null_add_flag",
        "reason": "Payment method applies to payment transactions, not customer invoice rows.",
    },
    {
        "table_name": "Sales_CustomerTransactions",
        "column_name": "InvoiceID",
        "action": "keep_null_add_flag",
        "reason": "InvoiceID applies to invoice transactions; customer payment rows can be standalone receipts.",
    },
    {
        "table_name": "Sales_CustomerTransactions",
        "column_name": "FinalizationDate",
        "action": "keep_null_add_flag",
        "reason": "Missing FinalizationDate represents open/unfinalized customer transactions.",
    },
    {
        "table_name": "Sales_OrderLines",
        "column_name": "PickingCompletedWhen",
        "action": "keep_null_add_flag",
        "reason": "Missing value means the line has not been picked yet; do not impute a fake timestamp.",
    },
    {
        "table_name": "Sales_Orders",
        "column_name": "BackorderOrderID",
        "action": "keep_null_add_flag",
        "reason": "BackorderOrderID is an optional self-reference; null means no prior backorder link.",
    },
    {
        "table_name": "Sales_Orders",
        "column_name": "PickedByPersonID",
        "action": "keep_null_add_flag",
        "reason": "Null can mean not picked yet or automated/system state; keep nullable picker key.",
    },
    {
        "table_name": "Sales_Customers",
        "column_name": "CreditLimit",
        "action": "keep_null_add_flag",
        "reason": "Credit limit is a real customer attribute; median imputation would distort credit analysis.",
    },
    {
        "table_name": "Sales_Customers",
        "column_name": "BuyingGroupID",
        "action": "keep_null_add_label",
        "reason": "Not every customer belongs to Tailspin/Wingtip; use No buying group for grouping only.",
    },
    {
        "table_name": "Warehouse_StockItems",
        "column_name": "ColorID",
        "action": "keep_null_add_label",
        "reason": "Some products legitimately have no color; do not assign the mode color.",
    },
    {
        "table_name": "Warehouse_StockItems",
        "column_name": "Brand",
        "action": "keep_original_add_label",
        "reason": "Only 18 of 227 products have a brand; mode imputation to Northwind would create false brand data.",
    },
    {
        "table_name": "Warehouse_StockItems",
        "column_name": "Size",
        "action": "keep_original_add_label",
        "reason": "Size is product-specific descriptive data; use Not specified for grouping only.",
    },
]


def read_tsv(table_name: str) -> pd.DataFrame:
    path = RAW_DIR / f"{table_name}.tsv"
    if not path.exists():
        raise FileNotFoundError(path)
    return pd.read_csv(
        path,
        sep="\t",
        dtype="object",
        keep_default_na=False,
        na_values=[""],
        low_memory=False,
    )


def is_present(series: pd.Series) -> pd.Series:
    return series.notna() & series.astype(str).str.len().gt(0)


def to_number(series: pd.Series) -> pd.Series:
    return pd.to_numeric(series, errors="coerce")


def bool_from_wwi(series: pd.Series) -> pd.Series:
    text = series.astype(str).str.strip().str.lower()
    return text.isin(["1", "true", "t", "yes", "y"])


def clean_null_byte(series: pd.Series) -> pd.Series:
    return series.where(series.isna(), series.astype(str).str.replace("\x00", "", regex=False))


def load_lookup(table_name: str, key_col: str, value_col: str) -> dict[str, str]:
    df = read_tsv(table_name)
    return dict(zip(df[key_col].astype(str), df[value_col].astype(str)))


def extract_country_of_manufacture(custom_fields: pd.Series) -> pd.Series:
    def parse_one(value: object) -> object:
        if pd.isna(value):
            return np.nan
        try:
            parsed = json.loads(str(value))
        except json.JSONDecodeError:
            return np.nan
        return parsed.get("CountryOfManufacture", np.nan)

    return custom_fields.map(parse_one)


# def add_common_missing_count(df: pd.DataFrame) -> pd.DataFrame:
#     df = df.copy()
#     df["MissingFieldCount"] = df.isna().sum(axis=1)
#     return df


def to_source_schema_table(table_name: str) -> str:
    schema, name = table_name.split("_", 1)
    return f"{schema}.{name}"


def build_scope_catalog() -> pd.DataFrame:
    rows = []
    for group in SCOPE_TABLE_GROUPS:
        for table_name in group["tables"]:
            rows.append(
                {
                    "category": group["category"],
                    "raw_table_name": table_name,
                    "source_schema_table": to_source_schema_table(table_name),
                    "raw_file": str((RAW_DIR / f"{table_name}.tsv").relative_to(PROJECT_ROOT)),
                    "clean_file": str((OUTPUT_DIR / f"{table_name}_clean.csv").relative_to(PROJECT_ROOT)),
                }
            )
    return pd.DataFrame(rows)


def clean_application_people(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for col in ["PhoneNumber", "FaxNumber", "EmailAddress"]:
        if col in df.columns:
            df[f"Has{col}"] = is_present(df[col])
    return df


def clean_purchasing_suppliers(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    for col in ["DeliveryAddressLine1", "DeliveryAddressLine2"]:
        if col in df.columns:
            df[col] = clean_null_byte(df[col]).replace("", np.nan)
    if "DeliveryMethodID" in df.columns:
        df["HasDeliveryMethod"] = is_present(df["DeliveryMethodID"])
    if "DeliveryAddressLine1" in df.columns:
        df["HasDeliveryAddressLine1"] = is_present(df["DeliveryAddressLine1"])
    return df


def clean_sales_customers(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["HasCreditLimit"] = is_present(df["CreditLimit"])
    df["HasBuyingGroup"] = is_present(df["BuyingGroupID"])
    df["HasAlternateContactPerson"] = is_present(df["AlternateContactPersonID"])
    df["BuyingGroupForAnalysis"] = np.where(df["HasBuyingGroup"], "Assigned buying group", "No buying group")
    return df


def clean_sales_customer_transactions(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    transaction_type = df["TransactionTypeID"].astype(str)
    df["HasPaymentMethod"] = is_present(df["PaymentMethodID"])
    df["HasInvoice"] = is_present(df["InvoiceID"])
    df["IsFinalizedFlag"] = bool_from_wwi(df["IsFinalized"])
    df["IsOpenTransaction"] = ~is_present(df["FinalizationDate"])
    df["PaymentMethodApplicability"] = np.select(
        [
            df["HasPaymentMethod"],
            transaction_type.eq("1") & ~df["HasPaymentMethod"],
        ],
        [
            "provided",
            "not_applicable_to_customer_invoice",
        ],
        default="missing_review",
    )
    df["InvoiceApplicability"] = np.select(
        [
            df["HasInvoice"],
            transaction_type.eq("3") & ~df["HasInvoice"],
        ],
        [
            "provided",
            "not_applicable_to_customer_payment",
        ],
        default="missing_review",
    )
    transaction_amount = to_number(df["TransactionAmount"])
    outstanding_balance = to_number(df["OutstandingBalance"])
    df["PaidAmount"] = transaction_amount - outstanding_balance
    df["OutstandingRatio"] = np.where(transaction_amount.ne(0), outstanding_balance / transaction_amount, np.nan)
    return df


def clean_sales_invoices(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["HasConfirmedDeliveryTime"] = is_present(df["ConfirmedDeliveryTime"])
    df["HasConfirmedReceivedBy"] = is_present(df["ConfirmedReceivedBy"])
    df["HasConfirmedDelivery"] = df["HasConfirmedDeliveryTime"] & df["HasConfirmedReceivedBy"]
    return df


def clean_sales_orders(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["HasPicker"] = is_present(df["PickedByPersonID"])
    df["HasBackorderOrder"] = is_present(df["BackorderOrderID"])
    df["IsOrderPickingCompleted"] = is_present(df["PickingCompletedWhen"])
    return df


def clean_sales_order_lines(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    quantity = to_number(df["Quantity"])
    picked_quantity = to_number(df["PickedQuantity"])
    df["IsLinePickingCompleted"] = is_present(df["PickingCompletedWhen"])
    df["UnpickedQuantity"] = quantity - picked_quantity
    df["FillRate"] = np.where(quantity.ne(0), picked_quantity / quantity, np.nan)
    df["IsFullyPicked"] = picked_quantity.ge(quantity)
    df["IsUnpickedLine"] = picked_quantity.eq(0) & ~df["IsLinePickingCompleted"]
    return df


def clean_warehouse_stock_items(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    color_lookup = load_lookup("Warehouse_Colors", "ColorID", "ColorName")
    df["HasColor"] = is_present(df["ColorID"])
    df["ColorNameForAnalysis"] = df["ColorID"].astype(str).map(color_lookup)
    df["ColorNameForAnalysis"] = df["ColorNameForAnalysis"].fillna("No color specified")
    df["HasBrand"] = is_present(df["Brand"])
    df["BrandForAnalysis"] = df["Brand"].fillna("Unbranded/Unknown")
    df["HasSize"] = is_present(df["Size"])
    df["SizeForAnalysis"] = df["Size"].fillna("Not specified")
    if "CustomFields" in df.columns:
        df["CountryOfManufacture"] = extract_country_of_manufacture(df["CustomFields"])
        df["HasCountryOfManufacture"] = is_present(df["CountryOfManufacture"])
    if "Tags" in df.columns:
        df["TagsForAnalysis"] = df["Tags"].fillna("[]")
    return df


TABLE_CLEANERS = {
    "Application_People": clean_application_people,
    "Purchasing_Suppliers": clean_purchasing_suppliers,
    "Sales_Customers": clean_sales_customers,
    "Sales_CustomerTransactions": clean_sales_customer_transactions,
    "Sales_Invoices": clean_sales_invoices,
    "Sales_Orders": clean_sales_orders,
    "Sales_OrderLines": clean_sales_order_lines,
    "Warehouse_StockItems": clean_warehouse_stock_items,
}


def apply_drop_rules(table_name: str, df: pd.DataFrame) -> tuple[pd.DataFrame, list[str]]:
    drop_cols = [col for col in DROP_COLUMNS.get(table_name, []) if col in df.columns]
    if not drop_cols:
        return df, []
    return df.drop(columns=drop_cols), drop_cols


def clean_table(table_name: str) -> tuple[pd.DataFrame, dict[str, object]]:
    raw = read_tsv(table_name)
    before_cols = set(raw.columns)
    cleaner = TABLE_CLEANERS.get(table_name)
    cleaned = cleaner(raw) if cleaner else raw.copy()
    cleaned, dropped_cols = apply_drop_rules(table_name, cleaned)
    # cleaned = add_common_missing_count(cleaned)
    added_cols = sorted(set(cleaned.columns) - before_cols)
    report = {
        "category": TABLE_CATEGORY.get(table_name, "Unmapped"),
        "table_name": table_name,
        "source_schema_table": to_source_schema_table(table_name),
        "input_rows": len(raw),
        "output_rows": len(cleaned),
        "input_columns": raw.shape[1],
        "output_columns": cleaned.shape[1],
        "dropped_columns": ", ".join(dropped_cols),
        "added_columns": ", ".join(added_cols),
        "remaining_missing_cells": int(cleaned.isna().sum().sum()),
    }
    return cleaned, report


def main() -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    REPORT_DIR.mkdir(parents=True, exist_ok=True)

    reports = []
    for table_name in DWH_SCOPE_TABLES:
        cleaned, report = clean_table(table_name)
        output_file = OUTPUT_DIR / f"{table_name}_clean.csv"
        cleaned.to_csv(output_file, index=False)
        report["output_file"] = str(output_file.relative_to(PROJECT_ROOT))
        reports.append(report)
        print(f"Saved {output_file.relative_to(PROJECT_ROOT)}: {len(cleaned):,} rows x {cleaned.shape[1]:,} cols")

    pd.DataFrame(reports).to_csv(REPORT_DIR / "cleaning_report.csv", index=False)
    pd.DataFrame(MISSING_RULES).to_csv(REPORT_DIR / "missing_treatment_rules.csv", index=False)
    build_scope_catalog().to_csv(REPORT_DIR / "scope_tables.csv", index=False)
    print(f"Saved {REPORT_DIR.relative_to(PROJECT_ROOT) / 'cleaning_report.csv'}")
    print(f"Saved {REPORT_DIR.relative_to(PROJECT_ROOT) / 'missing_treatment_rules.csv'}")
    print(f"Saved {REPORT_DIR.relative_to(PROJECT_ROOT) / 'scope_tables.csv'}")


if __name__ == "__main__":
    main()
