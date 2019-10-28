-- Deploy network_managrment:create_table_config to mysql

BEGIN;

CREATE TABLE IF NOT EXISTS config(
    id INT(11) NOT NULL AUTO_INCREMENT,
    gateway VARCHAR(100) NOT NULL,
    lan_subnets JSON NOT NULL,
    masquerade JSON NOT NULL,
    device VARCHAR(100) NOT NULL,
    broadcast_address VARCHAR(100),
    dhcp_subnet VARCHAR(100),
    dhcp_netmask VARCHAR(100),
    dhcp_range JSON,
    PRIMARY KEY (id)
) ENGINE=INNODB;

COMMIT;