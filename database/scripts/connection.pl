#!/usr/bin/env perl 

use strict;
use warnings;

use 5.20.0;
use DBI;

my $database = 'network_management';
my $hostname = 'localhost';
my $username = 'network_management';
my $password = '%@N@S*W1p8@s';

my $dsn = "DBI:mysql:database=$database;host=$hostname";
my $dbh = DBI->connect($dsn, $username, $password);

$dbh->disconnect;
