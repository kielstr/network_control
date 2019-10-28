-- Revert network_managrment:grant_access from mysql

BEGIN;

REVOKE ALL ON network_management.* FROM 'network_management'@'localhost';

COMMIT;
