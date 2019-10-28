-- Revert network_managrment:create_table_user from mysql

BEGIN;

DROP TABLE IF EXISTS user;

COMMIT;
