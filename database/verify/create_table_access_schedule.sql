-- Verify network_managrment:create_table_access_schedule on mysql

BEGIN;

SHOW CREATE TABLE access_schedule;

ROLLBACK;
