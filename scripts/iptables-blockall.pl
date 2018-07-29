#!/usr/bin/env perl

use 5.20.0;

use strict;
use warnings;

use YAML::Tiny;
use Data::Dumper::Concise;
use Capture::Tiny ':all';

my ( $config, $arg ) = @ARGV;

die "usage: $0 <config.yml> -A|-D\n" unless $arg and $arg =~ /^\-[A|D]$/;

my $yml_file = $config or die 'no config.yml';
my $yml = YAML::Tiny->read( $yml_file );
my $groups = $yml->[1];

my $iptables = '/sbin/iptables';
my $iptables_save = '/sbin/iptables-save';

for my $name ( keys %$groups ) {
    for my $device ( @{ $groups->{ $name }{ devices } } ) {
        next if $device->{hostname} eq 'kiels-laptop';
        
        my $cmd = "$iptables $arg FORWARD -s $device->{hostname} -j DROP";
        say $cmd;
        system $cmd;
    }
}
