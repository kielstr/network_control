-- Deploy network_managrment:grant_access to mysql

BEGIN;

GRANT ALL ON network_management.* TO 'network_management'@'localhost';

COMMIT;
