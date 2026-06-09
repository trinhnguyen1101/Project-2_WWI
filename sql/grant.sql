GRANT USAGE ON SCHEMA staging TO localhost;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA staging
TO localhost;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA staging
TO localhost;

SELECT current_user;

SELECT nspname,
       pg_catalog.pg_get_userbyid(nspowner) AS owner
FROM pg_namespace
WHERE nspname = 'staging';

SELECT has_schema_privilege('postgres', 'staging', 'USAGE');

ALTER SCHEMA staging OWNER TO postgres;

GRANT USAGE, CREATE ON SCHEMA staging TO postgres;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA staging
TO postgres;

GRANT USAGE, SELECT
ON ALL SEQUENCES IN SCHEMA staging
TO postgres;