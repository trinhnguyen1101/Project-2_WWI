# JDBC drivers

Put JDBC driver `.jar` files in this folder. Docker mounts this folder into
Apache Hop as `/files/jdbc` through `HOP_SHARED_JDBC_FOLDERS`.

For PostgreSQL, download the driver from:

```text
https://jdbc.postgresql.org/download/
```

Example target file:

```text
ETL/hop/jdbc/postgresql.jar
```
