-- Revert network_managrment:create_table_config from mysql

BEGIN;

DROP TABLE IF EXISTS config;

COMMIT;
