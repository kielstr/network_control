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

        my ( $stdout, $stderr, @result ) = capture {
            my $cmd = "$iptables -C FORWARD -s $device->{hostname} -j DROP";
            system $cmd;
        };

        my $found_rule = $? == 0 ? 1 : 0;

        if ( $found_rule and not $device->{ block_nightly }) {
            say "Removing old rule";
            my ( $stdout, $stderr, @result ) = capture {
                my $cmd = "$iptables -D FORWARD -s $device->{hostname} -j DROP";
                say $cmd;
                system $cmd;
            };  
            say $stdout if $stdout;
            say $stderr if $stderr;
        }

        next unless $device->{ block_nightly };

        if ( $arg eq '-D' and $found_rule ) {
            say "Deleting rule";
            my ( $stdout, $stderr, @result ) = capture {
                my $cmd = "$iptables -D FORWARD -s $device->{hostname} -j DROP";
                say $cmd;
                system $cmd;
            };
            say $stdout if $stdout;
            say $stderr if $stderr;
        } 
        elsif ( $arg eq '-A' and not $found_rule ) {
            say "Adding rule";
            my ( $stdout, $stderr, @result ) = capture {
                my $cmd = "$iptables -A FORWARD -s $device->{hostname} -j DROP";
                say $cmd;
                system $cmd;
            };
            say $stdout if $stdout;
            say $stderr if $stderr;
        }
    }
}

my ($stdout, $stderr, @result) = capture {
    system "$iptables_save > /etc/iptables/rules.v4";
    system $iptables, '-L', '-n';
};

die $stderr if $stderr;

say $stdout if $stdout;