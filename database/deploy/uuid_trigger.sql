-- Deploy network_managrment:uuid_trigger to mysql

BEGIN;

CREATE TRIGGER before_insert_user
    BEFORE INSERT ON user 
    FOR EACH ROW 
    SET new.uuid = COALESCE(new.uuid, UUID());

COMMIT;
