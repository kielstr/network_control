-- Deploy network_managrment:create_table_user to mysql

BEGIN;

CREATE TABLE IF NOT EXISTS user(
    id INT(11) NOT NULL AUTO_INCREMENT,
    uuid VARCHAR(100) NOT NULL UNIQUE,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100)  NOT NULL,
    active BOOLEAN NOT NULL DEFAULT true,
    upload_speed VARCHAR(20) DEFAULT '100mbit',
  	download_speed VARCHAR(20) DEFAULT '100mbit',
  	priority INT DEFAULT 1,
  	dt DATETIME NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id)
) ENGINE=INNODB;

COMMIT;
