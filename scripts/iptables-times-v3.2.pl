#!/usr/bin/env perl

use 5.20.0;

use strict;
use warnings;
use Date::Calc qw(Add_Delta_DHMS Date_to_Time);
use DateTime;
use Time::Piece;
use Getopt::Long;
use YAML::Tiny;
use Data::Dumper::Concise;
use Capture::Tiny ':all';
use Function::Parameters ':strict';
use List::MoreUtils qw(first_index);;

my $verbose = 0;
my $config;

GetOptions (
    "config=s"   => \$config,
    "verbose"  => \$verbose
) or die ("$0 -c <config> -v\n");

die "usage: $0 -c <config.yml> -v\n" unless $config;

my $yml_file = $config or die 'failed to read $config';

my $yml = YAML::Tiny->read( $yml_file );
my $users = $yml->[1];

my $iptables = '/sbin/iptables';
my $iptables_save = '/sbin/iptables-save';

my @wdays = qw/ sunday monday tuesday wednesday thursday friday saturday /;

my $t = localtime;

my $today = lc $t->fullday;
my $year = $t->year;
my $mon = $t->mon;
my $mday = $t->mday;
my $wday = $t->_wday;
my $hour = $t->hour;
my $min = $t->min;

$today = "friday";
$year = $t->year;
$mon = $t->mon;
$mday = 21;
$wday = $5;
$hour = 01;
$min = 00;

#$today = 'thursday';
#$wday = 4;
#$hour = 24;

my @days_in_order = map {( $wdays[$_] eq $today ? () : $wdays[$_] )} map {$_ % 7} $wday .. $wday + 6;
my @days_in_rev_order = reverse @days_in_order;

say 'Time now is ' . join ':', $t->hour, $t->min . " on $today"
    if $verbose;

for my $user ( sort keys %$users ) {
    next unless $user eq 'kiel';

    for my $device ( @{ $users->{ $user }{ devices } } ) {
        my $rules = $device->{ blocking } // next;

        my $today_unblock = $rules->{schedule}{$today}{unblock};
        my ( $today_unblock_hour, $today_unblock_min ) = split ':', $rules->{schedule}{$today}{unblock};
        my ( $today_unblock_year, $today_unblock_month, $today_unblock_day );

        my $today_block = $rules->{schedule}{$today}{block};
        my ( $today_block_hour, $today_block_min ) = split ':', $rules->{schedule}{$today}{block};
        my ( $today_block_year, $today_block_month, $today_block_day );

        say "$hour < $today_unblock_hour";

        say "$hour > $today_block_hour ";

        # Current hour is less than this days unblock time so lookup previous time.
        if ( $hour < $today_unblock_hour ) {
            say 1;
            ( $today_block_year, $today_block_month, $today_block_day, $today_block_hour, $today_block_min ) 
                = last_block_d_h_m( $rules );
        }
        # Current hour is more than this days block time so lookup next time.
        elsif ( $hour < $today_block_hour ) {
            say 2;

            # Day before
            ( $today_block_year, $today_block_month, $today_block_day, $today_block_hour, $today_block_min ) 
                = last_block_d_h_m( $rules );
        }
        else {
            say 3;
            # Day before
            ( $today_block_year, $today_block_month, $today_block_day, $today_block_hour, $today_block_min )
                = ( $year, $mon, $mday, ( map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$today}{block} ) );
        }

        # Current hour is less than this days unblock time so lookup previous time.
        if ( $hour < $today_block_hour ) {
            say 1;
            say "$hour < $today_block_hour";
            ( $today_unblock_year, $today_unblock_month, $today_unblock_day, $today_unblock_hour, $today_unblock_min )
                = next_unblock_d_h_m( $rules );
        }
        # Current hour is more than this days block time so lookup next time.
        elsif ( $hour > $today_unblock_hour ) {
            say 2;
            my $tomorrow = $wdays[(first_index { $_ eq $today } @wdays) +1];

            ( $today_unblock_year, $today_unblock_month, $today_unblock_day, $today_unblock_hour, $today_unblock_min ) 
                = Add_Delta_DHMS( $year, $mon, $mday, ( map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$tomorrow}{unblock} ), 00 ,1,0,0,0 );
        }
        else {
            # Day before
            say 3;
             ( $today_unblock_year, $today_unblock_month, $today_unblock_day, $today_unblock_hour, $today_unblock_min ) 
                = last_unblock_d_h_m( $rules );
        }


        my $block_dt = DateTime->new(
            year       => $today_block_year,
            month      => $today_block_month,
            day        => $today_block_day,
            hour       => $today_block_hour,
            minute     => $today_block_min,
            second     => 00,
            time_zone  => 'Australia/Melbourne',
        );

        my $block_time = $block_dt->epoch;


        my $unblock_dt = DateTime->new(
            year       => $today_unblock_year,
            month      => $today_unblock_month,
            day        => $today_unblock_day,
            hour       => $today_unblock_hour,
            minute     => $today_unblock_min,
            second     => 00,
            time_zone  => 'Australia/Melbourne',
        );

        my $unblock_time = $unblock_dt->epoch;

        say "\n\nblock_time: $block_time " . scalar localtime($block_time);
        say "now: " . time() . " " . scalar localtime();
        say "unblock_time: $unblock_time " . scalar localtime($unblock_time);

        my $now = time();
        if ( $t->epoch > $block_time && $t->epoch < $unblock_time ) {
            #$active = 1;

            say "Active";
        }
        else {
            say "Inactive";  
        }


    }
}

fun next_block_d_h_m ( $rules ) {
    # last block rule an day
    my $count = 0;
    for my $day (@days_in_rev_order) {
        $count++;
        if ( $rules->{schedule}{$day}{block} ) {
            return Add_Delta_DHMS( $year, $mon, $mday, (map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$day}{block}), 00 ,1,0,0,0 );
        }
    }
}

fun last_block_d_h_m ( $rules ) {
    # last block rule an day
    my $count = 0;
    for my $day (@days_in_rev_order) {
        $count++;
        if ( $rules->{schedule}{$day}{block} ) {
            return Add_Delta_DHMS( $year, $mon, $mday, (map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$day}{block}), 00, -1,0,0,0 );
        }
    }
}

fun next_unblock_d_h_m ( $rules ) {
    # next unblock rule an day
    my $count = 0;
    for my $day (@days_in_order) {
        $count++;
        if ( $rules->{schedule}{$day}{unblock} ) {
            return Add_Delta_DHMS( $year, $mon, $mday, (map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$day}{unblock}), 00 ,1,0,0,0 );
        }
    }
}

fun last_unblock_d_h_m ( $rules ) {
    # last block rule an day
    my $count = 0;
    for my $day (@days_in_order) {
        $count++;
        if ( $rules->{schedule}{$day}{unblock} ) {
            return Add_Delta_DHMS( $year, $mon, $mday, (map { sprintf '%02d', $_ } split ':', $rules->{schedule}{$day}{unblock}), 00, -1,0,0,0 );
        }
    }
}

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