-- Revert network_managrment:app_user from mysql

BEGIN;

DROP USER 'network_management'@'localhost';

COMMIT;
