-- Verify network_managrment:uuid_trigger on mysql

BEGIN;

SHOW CREATE TRIGGER before_insert_user;

ROLLBACK;
