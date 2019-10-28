#!/usr/bin/env perl 

use strict;
use warnings;
use 5.20.0;
use FindBin '$RealBin';
use lib $RealBin . '/../webapp/NetworkManagement/lib/', $RealBin . '/../NC/lib';
use Path::Tiny;

use NC::Database;
use Cpanel::JSON::XS;
use Data::Dumper::Concise;

my $dhcp_known_host_file = '/etc/dhcp/known_hosts.conf';

path($dhcp_known_host_file)->touch unless -e $dhcp_known_host_file;
my $ctime = path($dhcp_known_host_file)->stat->[9];

my $schema = NC::Database->connect();

my $count = $schema->resultset('Device')->search(
	{ 'dt' => \"> FROM_UNIXTIME($ctime)" } 
)->count || $schema->resultset('User')->search(
	{ 'dt' => \"> FROM_UNIXTIME($ctime)" } 
)->count;

unless ( @ARGV and $ARGV[0] eq '-f' ){
	exit if $count == 0;
}

say "generating file";
open my $fh, '>', $dhcp_known_host_file
    or die "can't open file $dhcp_known_host_file: $!";

select $fh;

my $conf_rs = $schema->resultset('Config')->next;

say "group {";

say "\tsubnet " . $conf_rs->dhcp_subnet . " netmask " . $conf_rs->dhcp_netmask . " {";
say "\t\trange " . join ( ' ', @{ decode_json ( $conf_rs->dhcp_range ) } ). ";" if defined $conf_rs->dhcp_range;
say "\t\toption routers " . $conf_rs->gateway . ";";
say "\t\toption broadcast-address " . $conf_rs->broadcast_address . " ;";
say "\t}";

my $users_rs = $schema->resultset('User');

while(my $user = $users_rs->next) {

	next unless $user->active;

   	for my $device ( $user->devices ) {

   		next unless $device->dhcp;

   		say "\thost " . $device->hostname . " {";
      say "\t\thardware ethernet " . $device->mac . ";";
      say "\t\tfixed-address " . $device->ip . ";";
      say sprintf "\t\toption domain-name-servers %s;", join ',', @{ decode_json $device->domain_name_servers} if $device->domain_name_servers;
      say "\t}";
   	};
}

say "}";

close $fh;

system "service isc-dhcp-server restart";


