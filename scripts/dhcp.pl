#!/usr/bin/env perl

use 5.20.0;
use strict;
use warnings;

use YAML::Tiny;
use Data::Dumper::Concise;

my $dhcp_known_host_file = '/etc/dhcp/known_hosts.conf';
my $config = '/home/kiel/network_control/config/config.yml';

my $yml_file = $config or die 'no config.yml';
my $yml = YAML::Tiny->read( $yml_file );
my $local_network = $yml->[0];
my $groups = $yml->[1];

open my $fh, '>', $dhcp_known_host_file
    or die "can't open file $dhcp_known_host_file: $!";

select $fh;

say "group {";

say "\tsubnet 192.168.1.0 netmask 255.255.255.0 {";
say "\t\t#range 192.168.1.100 192.168.1.200;";
say "\t\toption routers 192.168.1.10;";
say "\t\toption broadcast-address 192.168.1.255;";
say "\t}";

for my $name ( keys %$groups ) {
    for my $device ( map { ( $_->{ dhcp } and $_->{ dhcp } eq 'true' ) ? $_ : () } @{ $groups->{ $name }{ devices } } ) {
        say "\thost $device->{ hostname } {";
        say "\t\thardware ethernet $device->{mac};";
        say "\t\tfixed-address $device->{ip};";
        say "\t}";
    }
}

say "}";

close $fh;

system "service isc-dhcp-server restart";

