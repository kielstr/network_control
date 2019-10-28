-- Revert network_managrment:create_table_access_schedule from mysql

BEGIN;

DROP TABLE IF EXISTS access_schedule;

COMMIT;
