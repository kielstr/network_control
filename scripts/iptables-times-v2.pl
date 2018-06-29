#!/usr/bin/env perl

use 5.20.0;

use strict;
use warnings;

use YAML::Tiny;
use Data::Dumper::Concise;
use Capture::Tiny ':all';

my $config = $ARGV[0];

die "usage: $0 <config.yml>\n" unless $config;

my $yml_file = $config or die 'no config.yml';
my $yml = YAML::Tiny->read( $yml_file );
my $groups = $yml->[1];

my $iptables = '/sbin/iptables';
my $iptables_save = '/sbin/iptables-save';

my @wdays = qw/monday tuesday wednesday thursday friday saturday sunday/;

my ( $min, $hour, $day ) = map { sprintf '%02d', $_ } ( localtime( time ) )[ 1, 2, 6 ];
$day = $wdays[ $day -1 ];

#say 'Time now is ' . join ':', $hour, $min . " on $day";

for my $name ( keys %$groups ) {
    for my $device ( @{ $groups->{ $name }{ devices } } ) {

        my $rules = $device->{ blocking };

        my ( $stdout, $stderr, @result ) = capture {
            my $cmd = "$iptables -C FORWARD -s $device->{hostname} -j DROP";
            system $cmd;
        };

        my $found_rule = $? == 0 ? 1 : 0;

        if ( $found_rule and not $rules  
            or $found_rule and $rules and $rules->{ active } eq 'false' 
        ) {
            #say "Removing old rule";
            my ( $stdout, $stderr, @result ) = capture {
                my $cmd = "$iptables -D FORWARD -s $device->{hostname} -j DROP";
                say $cmd;
                system $cmd;
            };  
            say $stdout if $stdout;
            say $stderr if $stderr;
        }

        next unless $rules and $rules->{ active } eq 'true';

        unless ( exists $rules->{ schedule }{ $day } ) {
            #say "no rules for today";
            next;
        }

        my $action;
        my $todays_rules = $rules->{ schedule }{ $day };

        if ( $todays_rules->{ block } ) {
            my ( $block_hour, $block_min ) = map { sprintf '%02d', $_ } split ':', $todays_rules->{ block };
            #say 'Block at ' . join ':', $block_hour, $block_min;

            if ( $hour == $block_hour and $min == $block_min ) {
                $action = 'add';
            }
        }

        if ( $todays_rules->{ unblock } ) {
            my ( $unblock_hour, $unblock_min ) = map { sprintf '%02d', $_ }  split ':', $todays_rules->{ unblock };
            #say 'Unblock at ' . join ':', $unblock_hour, $unblock_min;

            if ($hour == $unblock_hour and $min == $unblock_min) {
                $action = 'delete';
            }
        }

        next unless $action;

        if ( $action eq 'delete' and $found_rule ) {
            #say "Deleting rule";
            my ( $stdout, $stderr, @result ) = capture {
                my $cmd = "$iptables -D FORWARD -s $device->{hostname} -j DROP";
                say $cmd;
                system $cmd;
            };
            say $stdout if $stdout;
            say $stderr if $stderr;
        } 
        elsif ( $action eq 'add' and not $found_rule ) {
            #say "Adding rule";
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
    #system $iptables, '-L', '-n';
};

say $stderr if $stderr;
say $stdout if $stdout;