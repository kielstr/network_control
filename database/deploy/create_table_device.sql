-- Deploy network_managrment:create_table_device to mysql

BEGIN;

CREATE TABLE IF NOT EXISTS device(
    id INT NOT NULL AUTO_INCREMENT,
    uuid VARCHAR(100) NOT NULL,
    download_speed VARCHAR(100) NOT NULL,
    upload_speed VARCHAR(100) NOT NULL,
    hostname VARCHAR(100) NOT NULL,
    mac VARCHAR(100),
    ip VARCHAR(100),
    priority INT,
    description VARCHAR(100),
    dhcp BOOLEAN,
    active BOOLEAN NOT NULL DEFAULT true,
    domain_name_servers JSON,
    dt DATETIME NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (uuid) REFERENCES user(uuid)
) ENGINE=INNODB;

COMMIT;
