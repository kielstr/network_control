#!/usr/bin/env perl

# Need to make this script look at the block and unblock times then check the state of chain is correct. 

use 5.20.0;

use strict;
use warnings;

use Data::Dumper 'Dumper';
use YAML::Tiny;
use Data::Dumper::Concise;
use Capture::Tiny ':all';
use Function::Parameters ':strict';

my $config = $ARGV[0];
my $verbose = $ARGV[1];

die "usage: $0 <config.yml>\n" unless $config;

my $yml_file = $config or die 'no config.yml';
my $yml = YAML::Tiny->read( $yml_file );
my $groups = $yml->[1];

my $iptables = '/sbin/iptables';
my $iptables_save = '/sbin/iptables-save';

my @wdays = qw/ monday tuesday wednesday thursday friday saturday sunday /;

my ( $min, $hour, $day ) = map { sprintf '%02d', $_ } ( localtime( time ) )[ 1, 2, 6 ];
$day = $wdays[ $day -1 ];

say 'Time now is ' . join ':', $hour, $min . " on $day"
    if $verbose;

# Block
#$hour = 23;
#$min = 30;
#$day = "monday";

# Unblock
#$hour = 6;
#$min = 00;
#$day = "monday";

my $iptables_changed = 0;

for my $name ( keys %$groups ) {
    my $blocked = 0;

    say "-- $name -- " if $verbose;

    if ( defined $groups->{ $name }{ blocked } and $groups->{ $name }{ blocked } eq 'true' ) {
        $blocked = 1;
    }

    for my $device ( @{ $groups->{ $name }{ devices } } ) {

        my $rules = $device->{ blocking } // next;
        my $todays_rules = $rules->{ schedule }{ $day };
        my $action = action($todays_rules) // "ignore";

        run ( "$iptables -C FORWARD -s $device->{hostname} -j DROP" );

        my $found_rule = $? == 0 ? 1 : 0;

        if ( $blocked and $found_rule ) {
            say "Skipping. Rule found and user is blocked" if $verbose;
            next;
        } 
        elsif ( $blocked and !$found_rule ) {
            say "Adding global user is block." if $verbose;
            run ( "$iptables -A FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
            next
        }
        elsif ( !$blocked and $found_rule and $action ne 'add' and $action ne 'delete' ) {
            say "Removing global user is block. [$action]" if $verbose;

            # ** Need to know if the rule for this device is active in the time period 
            # before we delete it.
            
            #run ( "$iptables -D FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
            next;
        }

        next unless $rules->{ active } eq 'true';

        if ( $found_rule and not $rules  
            or $found_rule and $rules and $rules->{ active } eq 'false' 
        ) {
            say "Removing old rule" if $verbose;;
            $iptables_changed++;
            run ( "$iptables -D FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
        }

        next unless $rules and $rules->{ active } eq 'true';

        unless ( exists $rules->{ schedule }{ $day } ) {
            say "no rules for today" if $verbose;;
            next;
        }

        if ( $action eq 'delete' and $found_rule ) {
            say "Deleting rule"
                if $verbose;

            $iptables_changed++;
            run ( "$iptables -D FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
        } 
        elsif ( $action eq 'add' and not $found_rule ) {
            say "Adding rule"
                if $verbose;

            $iptables_changed++;
            run ( "$iptables -A FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
        }
    }
}

run ( "$iptables_save > /etc/iptables/rules.v4", { showerr => 1 } )
    if $iptables_changed;

fun run ( $cmd, $opt = undef ) {
    say $cmd if $verbose;
    my ( $stdout, $stderr, @result ) = capture {
        system $cmd;
    };
    say $stdout if $stdout and $opt->{verbose};
    say $stderr if $stderr and $opt->{verbose} or $opt->{showerr};
}

fun action ( $todays_rules ) {
    my $action;

    if ( $todays_rules->{ block } ) {
        my ( $block_hour, $block_min ) = map { sprintf '%02d', $_ } split ':', $todays_rules->{ block };
        say 'Block at ' . join ':', $block_hour, $block_min
            if $verbose;

        if ( $hour == $block_hour and $min == $block_min ) {
            $action = 'add';
        }
    }

    if ( $todays_rules->{ unblock } ) {
        my ( $unblock_hour, $unblock_min ) = map { sprintf '%02d', $_ }  split ':', $todays_rules->{ unblock };
        say 'Unblock at ' . join ':', $unblock_hour, $unblock_min
            if $verbose;

        if ( $hour == $unblock_hour and $min == $unblock_min ) {
            $action = 'delete';
        }
    }

    return $action;
}