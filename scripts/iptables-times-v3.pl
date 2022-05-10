#!/usr/bin/env perl

use 5.20.0;

use strict;
use warnings;
use Date::Calc qw(Add_Delta_Days Day_of_Week Date_to_Time);
use Time::Piece;

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




my $t = localtime;
print "Time is $t\n";
print "Year is ", $t->year, "\n";


my $today = lc $t->fullday;

say "Today is $today";

exit;

__END__




my ( $sec, $min, $hour, $day, $mon, $year, $wday ) = ( localtime( time ) )[ 0, 1, 2, 3, 4, 5, 6 ];
my $today = $wdays[ ($wday -1) ];
my @days_in_order = map {( $wdays[$_] eq $today ? () : $wdays[$_] )} map {$_ % 7} $wday .. $wday + 6;
my @days_in_rev_order = reverse @days_in_order;


$year += 1900;
$mon++;

$mon = sprintf '%02d', $mon;
$day = sprintf '%02d', $day;

#$wday = $wdays[ ($wday -1) ];

#my $today = $wdays[ ($wday -1) ];
$wday = $wdays[ ($wday -1) ];

say 'Time now is ' . join ':', $hour, $min . " on $today"
    if $verbose;

# Block
#$hour = 23;
#$min = 30;
#$wday = "monday";

# Unblock
#$hour = 6;
#$min = 00;
#$day = "monday";

my $iptables_changed = 0;

for my $name ( keys %$groups ) {
    my $blocked = 0;

    say "-- $name -- " if $verbose;
    next unless $name eq 'kiel';

    if ( defined $groups->{ $name }{ blocked } and $groups->{ $name }{ blocked } eq 'true' ) {
        $blocked = 1;
    }

    for my $device ( @{ $groups->{ $name }{ devices } } ) {

        my $rules = $device->{ blocking } // next;
        my $active = rule_is_active( $rules );

        # last block rule an day
        for my $day (@days_in_rev_order) {
            if ( $rules->{schedule}{$day}{block} ) {
                say "last block $day -> $rules->{schedule}{$day}{block}";
                last;
            }
        }
        say "todays unblock $rules->{schedule}{$today}{unblock}";

        say "todays block $rules->{schedule}{$today}{block}";

        # next unblock rule and day
        for my $day (@days_in_order) {
            if ( $rules->{schedule}{$day}{unblock} ) {
                say "next unblock $day -> $rules->{schedule}{$day}{unblock}";
                last;
            }
        }

        next;

        say "active $active";

        run ( "$iptables -C FORWARD -s $device->{hostname} -j DROP" );

        my $found_rule = $? == 0 ? 1 : 0;

        if ( $blocked && !$found_rule ) {
            say "Adding block." if $verbose;
            run ( "$iptables -A FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
            $iptables_changed++;

        }
        elsif ( !$blocked && $found_rule && !$active) {
            say "Removing block." if $verbose;
            run ( "$iptables -D FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
            $iptables_changed++;

        }
        elsif ( $active && !$found_rule) {
            say "Adding block." if $verbose;
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


fun rule_is_active ( $rules ) {
    my $active = 0;
    my $start_blocking_time;
    my $start_block_hour;
    my $start_block_min;
    my $start_block_time;

    my $stop_blocking_time;
    my $stop_block_hour;
    my $stop_block_min;
    my $stop_block_time;

    my ($next_year, $next_mon, $next_day) = Add_Delta_Days( $year, $mon, $day, 1);
    my $next_dow = Day_of_Week($next_year, $next_mon, $next_day);
    my $tomorrow_day = $wdays[($next_dow - 1)];

    if (defined $rules->{active} and $rules->{active} eq 'false') {
        return $active;
    }
    elsif ( (defined $rules->{active} and $rules->{active} eq 'true') && !$rules->{schedule}) {
        $active = 1;
    }

    if ( $rules->{schedule}{$wday}{block} ) {
        $start_blocking_time = $rules->{schedule}{$wday}{block};
        ( $start_block_hour, $start_block_min ) = map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$wday}{block};
        $start_block_time = Date_to_Time( $year, $mon ,$day, $start_block_hour, $start_block_min , 00 );
    }

    if ( $rules->{schedule}{$tomorrow_day}{unblock} ) {
        $stop_blocking_time  = $rules->{schedule}{$tomorrow_day}{unblock};
        ( $stop_block_hour, $stop_block_min ) = map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$wday}{block};
        $stop_block_time = Date_to_Time( $next_year, $next_mon ,$next_day, $stop_block_hour , $stop_block_min , 00 );
    }

    if ( $start_block_time && $stop_block_time) {
        my $time_now = Date_to_Time( $year, $mon, $day, $hour, $min, $sec);

        say "$time_now > $start_block_time && $time_now < $stop_block_time";

        if ( $time_now > $start_block_time && $time_now < $stop_block_time ) {
            $active = 1;
        }
    }

    say "fun active $active";
    return $active;
}