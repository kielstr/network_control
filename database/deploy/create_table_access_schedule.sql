-- Deploy network_managrment:create_table_access_schedule to mysql

BEGIN;

CREATE TABLE IF NOT EXISTS access_schedule(
    id INT NOT NULL AUTO_INCREMENT,
    uuid VARCHAR(100) NOT NULL,
    device_id INT,
    day VARCHAR(100) NOT NULL,
  	block TIME,
  	unblock TIME,
  	dt DATETIME NOT NULL ON UPDATE CURRENT_TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    FOREIGN KEY (uuid) REFERENCES user(uuid),
    FOREIGN KEY (device_id) REFERENCES device(id)
) ENGINE=INNODB;

COMMIT;
