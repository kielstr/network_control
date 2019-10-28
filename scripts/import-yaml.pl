#!/usr/bin/env perl 

#dbicdump -Ilib -o dump_directory=./lib -o components='["InflateColumn::DateTime"]' -o preserve_case=1 NetworkManagement::Schema dbi:mysql:database=network_management kiel 'Q4*b2&3iWUyg'          '{ quote_char => "`" }'

use strict;
use warnings;
use 5.20.0;
use FindBin '$RealBin';
use lib $RealBin . '/../lib';
use NetworkManagement::Schema;
use YAML::Tiny;
use Cpanel::JSON::XS;
use Data::Dumper::Concise;

my $config = $ARGV[0];
my $verbose = $ARGV[1];

die "usage: $0 <config.yml>\n" unless $config;

my $yml_file = $config or die 'no config.yml';
my $yml = YAML::Tiny->read( $yml_file );

my $conf = $yml->[0];

my $schema = NetworkManagement::Schema->connect(
    'dbi:mysql:database=network_management:host=namik;port=3306', 
    'kiel',
    'Q4*b2&3iWUyg',
);

#my $config_rs = $schema->resultset('Config');
#my $new_config = $config_rs->new({});
#$new_config->gateway($conf->{'gateway'});
#$new_config->lan_subnets(encode_json $conf->{'lan_subnets'});
#$new_config->masquerade( encode_json $conf->{'masquerade'} );
#$new_config->device($conf->{'device'});
#$new_config->broadcast_address($conf->{'broadcast-address'});
#$new_config->dhcp_subnet($conf->{'dhcp-subnet'});
#$new_config->dhcp_netmask($conf->{'dhcp-netmask'});
#$new_config->dhcp_range(encode_json [split (' ', $conf->{'dhcp-range'})]);
#$new_config->insert;


my $users = $yml->[1];

#print Dumper $users;

my $user_rs = $schema->resultset('User');

my $device_rs = $schema->resultset('Device');

my $as_rs = $schema->resultset('AccessSchedule');

for my $name ( keys %$users ) {
	my $user = $user_rs->find( {firstname => ucfirst $name } ) // $user_rs->find( {firstname => 'Guest'} );
	say "$name " . $user->uuid;

	for my $device ( @{$users->{$name}{'devices'}}) {

		my $new_device = $device_rs->new({});
		$new_device->uuid($user->uuid);

		$new_device->download_speed($device->{'download_speed'});
		$new_device->upload_speed($device->{'upload_speed'});
		$new_device->description($device->{'desc'});
		$new_device->hostname($device->{'hostname'});
		$new_device->priority($device->{'priority'});
		$new_device->mac($device->{'mac'});
		$new_device->ip($device->{'ip'});
		$new_device->dhcp(($device->{'dhcp'} eq "true" ? 1 : 0));

		$new_device->domain_name_servers(encode_json $device->{'domain-name-servers'})
			if defined $device->{'domain-name-servers'};

		$new_device->insert;

	}

	for my $device ( @{ $users->{$name}{'devices'} } ) {

		next unless defined $device->{blocking}{schedule};

		for my $day ( keys %{ $device->{blocking}{schedule} } ) {

			my $known_device = $device_rs->find( {mac => $device->{'mac'} } ) // next;
			my $new_as = $as_rs->new({});
			$new_as->uuid($user->uuid);
			$new_as->device_id($known_device->id);
			$new_as->day($day);
			$new_as->block($device->{blocking}{schedule}{$day}{block});
			$new_as->unblock($device->{blocking}{schedule}{$day}{unblock});
			$new_as->insert;
		}
	}
} 

