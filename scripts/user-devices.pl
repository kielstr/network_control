#!/usr/bin/env perl 

use strict;
use warnings;
use 5.20.0;
use FindBin '$RealBin';
use lib $RealBin . '/../lib';

use NetworkManagement::Schema;
use Cpanel::JSON::XS;
use Data::Dumper::Concise;

my $schema = NetworkManagement::Schema->connect(
    'dbi:mysql:database=network_management:host=namik;port=3306', 
    'kiel',
    'Q4*b2&3iWUyg',
);

my $search_rs = $schema->resultset('User')->search(
  { 'firstname' => 'Isac' },
);

while(my $result = $search_rs->next) {
	say $result->firstname;
   	for my $device ( $result->devices ) {
   		say join ' - ', $device->ip, $device->description;

   		for my $as ( $device->access_schedules ) {
	   		say join ' - ', $as->day, $as->block, $as->unblock;
	   	};
   	};
}
