-- Deploy network_managrment:app_user to mysql

BEGIN;

CREATE USER 'network_management'@'localhost' IDENTIFIED BY '%@N@S*W1p8@s';

COMMIT;
