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
    for my $device ( map {$_->{block_nightly} ? $_ : () } @{ $groups->{ $name }{ devices } } ) {
        my ($stdout, $stderr, @result) = capture {
            my $cmd = "$iptables $arg FORWARD -s $device->{hostname} -j DROP";
            say $cmd;
            system $cmd;
        };

        say $stdout if $stdout;

        say $stderr if $stderr;
    }
}

my ($stdout, $stderr, @result) = capture {
    system "$iptables_save > /etc/iptables/rules.v4";
    system $iptables, '-L', '-n';
};

die $stderr if $stderr;

say $stdout if $stdout;