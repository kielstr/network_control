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
use Sys::Syslog qw(:DEFAULT setlogsock);
use File::Basename;

use constant {
    TRUE   => 1,
    FALSE  => 0,
};

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

my $today   = lc $t->fullday;
my $year    = $t->year;
my $mon     = $t->mon;
my $mday    = $t->mday;
my $wday    = $t->_wday;
my $hour    = $t->hour;
my $min     = $t->min;
my $now     = $t->epoch;

#$today = "thursday";
#$year = $t->year;
#$mon = $t->mon;
#$mday = 21;
#$wday = 5;
#$hour = 22;
#$min = 30;
#
#my $dt = DateTime->new(
#    year       => $year,
#    month      => $mon,
#    day        => $mday,
#    hour       => $hour,
#    minute     => $min,
#    second     => 00,
#    time_zone  => 'Australia/Melbourne',
#);
#
#$now = $dt->epoch;

my @days_in_order = map {( $wdays[$_] eq $today ? () : $wdays[$_] )} map {$_ % 7} $wday .. $wday + 6;
my @days_in_rev_order = reverse @days_in_order;

say 'Time now is ' . join ':', $t->hour, $t->min . " on $today"
    if $verbose;

my $iptables_changed = FALSE;

setlogsock("unix");
openlog(basename($0), "nowait", "user");

for my $user ( sort keys %$users ) {
    #next unless $user eq 'kiel';

    my $user_level_block = user_level_status( $users->{ $user } );

    for my $device ( @{ $users->{ $user }{ devices } } ) {
        my $rules = $device->{ blocking } // next;
        my $block_active = device_level_status( $rules );

        run ( "$iptables -C FORWARD -s $device->{hostname} -j DROP" );
        my $found_rule = $? == 0 ? TRUE : FALSE;

        # User level blocking active
        if ( $user_level_block && !$found_rule ) {
            say "$user -- adding user level block for host " . $device->{hostname} if $verbose;
            syslog("info", "$user -- adding user level block for host " . $device->{hostname});

            run ( "$iptables -A FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
            $iptables_changed++;

        }
        # User level deactive and iptable rule found (active->deactive)
        # or chedule rule deactive
        elsif ( !$user_level_block && $found_rule && !$block_active) {
            say "$user -- removing block for host " . $device->{hostname} if $verbose;
            syslog("info", "$user -- removing block for host " . $device->{hostname});
            run ( "$iptables -D FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } );
            $iptables_changed++;

        }
        # Schedule rule active.
        elsif ( $block_active && !$found_rule) {
            if ( defined $rules->{active} and $rules->{active} eq 'true' ) {
                say "$user -- adding device level block for host " . $device->{hostname} if $verbose;
                syslog("info", "$user -- adding device level block for host " . $device->{hostname});
                $iptables_changed++;
                run ( "$iptables -A FORWARD -s $device->{hostname} -j DROP", { showerr => 1 } ); 
            }
        }
    }
}

run ( "$iptables_save > /etc/iptables/rules.v4", { showerr => 1 } )
    if $iptables_changed;

closelog();

# User level user blocking 
# username:
#   blocked: false

fun user_level_status ( $user ) {
    if ( defined $user->{ blocked } and $user->{ blocked } eq 'true' ) {
        return TRUE;
    }
    return FALSE;
}

fun device_level_status ( $rules ) {
    my $block_active = FALSE;

    if (defined $rules->{active} and $rules->{active} eq 'false') {
        $block_active = FALSE;
    }
    elsif ( $rules->{schedule} ) {

            my %today_block_time = todays_date_time( 'block', $rules );
            say "-- Today Block Time --\n" . Dumper \%today_block_time
                if $verbose;

            my %next_block_time = next_date_time( 'block', $rules );
            say "-- Next Block Time --\n" . Dumper \%next_block_time
                if $verbose;

            my %previous_block_time = previous_date_time( 'block', $rules );
            say "-- Previous Block Time --\n" . Dumper \%previous_block_time
                if $verbose;

            my %today_unblock_time = todays_date_time( 'unblock', $rules );

            say "-- Today Unblock Time --\n" . Dumper \%today_unblock_time
                if $verbose;

            my %next_unblock_time = next_date_time( 'unblock', $rules );
            say "-- Next Unblock Time --\n" . Dumper \%next_unblock_time
                if $verbose;

            my %previous_unblock_time = previous_date_time( 'unblock', $rules );
            say "-- Previous Unblock Time --\n" . Dumper \%previous_unblock_time
                if $verbose;

            # Should todays block rule be applied.
            if ( 
                ( $today_block_time{epoch} && $now >= $today_block_time{epoch} ) 
                && ( $next_unblock_time{epoch} && $now <= $next_unblock_time{epoch} )
            ) {
                say "Todays block time is active" if $verbose;
                $block_active = TRUE;
            }
            # Should the previous block rule be active
            elsif ( 
                $now >= $previous_block_time{epoch} 
                && ( $today_unblock_time{epoch} && $now <= $today_unblock_time{epoch} ) 
            ) {
                say "Previous block time is active" if $verbose;
                $block_active = TRUE;
            }
            else {
                say "Inactive" if $verbose;
            }
        }
        elsif (defined $rules->{active} and $rules->{active} eq 'true') {
            $block_active = TRUE;
        }

        return $block_active;
}

fun todays_date_time ($type, $rules) {

    return unless defined $rules->{schedule}{$today}{$type};

    my ($t_hour, $t_min) = (split ':', $rules->{schedule}{$today}{$type});
    my $dt = DateTime->new(
        year       => $year,
        month      => $mon,
        day        => $mday,
        hour       => $t_hour,
        minute     => $t_min,
        second     => 00,
        time_zone  => 'Australia/Melbourne',
    );
    my %today_unblock_time = (
        epoch    => $dt->epoch,
        fullday => $today,
        year    => $year,
        min     => $mon,
        mday    => $mday,
        hour    => $t_hour,
        min     => $t_min, 
        sec     => 00,
    );
}

fun next_date_time ( $type, $rules ) {
    # last block rule an day
    my $count = 0;
    my ($next_day, @next_date_time);

    for my $day (@days_in_order) {
        $count++;
        if ( $rules->{schedule}{$day}{$type} ) {
           @next_date_time = ( Add_Delta_DHMS(
                    $year,
                    $mon,
                    $mday, 
                    (split ':', $rules->{schedule}{$day}{$type}),
                    00, 
                    $count, 0, 0, 0 
                )
            );
           $next_day = $day;
           last;
        }
    }

    my $dt = DateTime->new(
        year       => $next_date_time[0],
        month      => $next_date_time[1],
        day        => $next_date_time[2],
        hour       => $next_date_time[3],
        minute     => $next_date_time[4],
        second     => 00,
        time_zone  => 'Australia/Melbourne',
    );

    return (
        epoch    => $dt->epoch,
        fullday  => $next_day,
        year     => $next_date_time[0],
        mon      => $next_date_time[1],
        mday     => $next_date_time[2],
        hour     => $next_date_time[3],
        min      => $next_date_time[4],
        sec      => $next_date_time[5],
    );
}

fun previous_date_time ( $type, $rules ) {
    # last block rule an day
    my $count = 0;
    my ($next_day, @next_date_time);

    for my $day (@days_in_rev_order) {
        $count++;
        if ( $rules->{schedule}{$day}{$type} ) {
           @next_date_time = ( Add_Delta_DHMS(
                    $year,
                    $mon,
                    $mday, 
                    (split ':', $rules->{schedule}{$day}{$type}),
                    00, 
                    -$count, 0, 0, 0 
                )
            );
           $next_day = $day;
           last;
        }
    }

    my $dt = DateTime->new(
        year       => $next_date_time[0],
        month      => $next_date_time[1],
        day        => $next_date_time[2],
        hour       => $next_date_time[3],
        minute     => $next_date_time[4],
        second     => 00,
        time_zone  => 'Australia/Melbourne',
    );

    return (
        epoch    => $dt->epoch,
        fullday  => $next_day,
        year     => $next_date_time[0],
        mon      => $next_date_time[1],
        mday     => $next_date_time[2],
        hour     => $next_date_time[3],
        min      => $next_date_time[4],
        sec      => $next_date_time[5],
    );
}

fun run ( $cmd, $opt = undef ) {
    say $cmd if $verbose;
    my ( $stdout, $stderr, @result ) = capture {
        system $cmd;
    };
    say $stdout if $stdout and $opt->{verbose};
    say $stderr if $stderr and $opt->{verbose} or $opt->{showerr};
}
