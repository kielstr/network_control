-- Revert network_managrment:uuid_trigger from mysql

BEGIN;

DROP TRIGGER before_insert_user;

COMMIT;
