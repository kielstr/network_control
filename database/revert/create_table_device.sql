-- Revert network_managrment:create_table_device from mysql

BEGIN;

DROP TABLE IF EXISTS device;

COMMIT;
