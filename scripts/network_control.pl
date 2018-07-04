#!/usr/bin/env perl

use 5.20.0;
use strict;
use warnings;
use Data::Dumper::Concise;

use FindBin '$RealBin';
use lib "$RealBin/../NC/lib";

use YAML::Tiny;

use NC::TC::Qdisc;
use NC::TC::Queue;
use NC::Device;

my $yml_file = shift or die 'no config.yml';

my $yml = YAML::Tiny->read( $yml_file );

my %local_network = %{ $yml->[0] };

my %devices = %{ $yml->[1] };

$NC::Verbose = 0;
$NC::DryRun = 0;

my $qd = NC::TC::Qdisc->new( 
    handle => '1:', 
    device => $local_network{ device }, 
    default => 1 )
->clear
->create;

# Clear NAT 
$qd->run( 'iptables -t nat -F' );

# Clear marking rules
$qd->run( 'iptables -t mangle -F' );

# Clear chains
$qd->run( 'iptables -F' );

my $parent_handle = $qd->next_queue_id;

my $parent_queue = NC::TC::Queue->new(
    device       => $qd->device,
    id           => $qd->handle . $parent_handle,
    priority     => 1,
    parent       => $qd->handle,
    rate         => '100mbit',
    ceiling      => '100mbit',
)->create;


$qd->run( sprintf 'tc filter add dev %s parent 1:0 protocol ip prio 1 handle %s fw classid %s', 
    $local_network{ device },
    $qd->next_queue_id,
    $qd->handle . $qd->next_queue_id,
);

# Masquerade for local networks.
for my $subnet ( @{ $local_network{ masquerade } } ) {
    $qd->run( sprintf 'iptables -t nat -A POSTROUTING -s %s -o %s -j MASQUERADE', $subnet, $local_network{ device } );
}

# Fast queue for local traffic.
for my $subnet ( @{ $local_network{ lan_subnets } } ) {
    $qd->run( sprintf 'iptables -t mangle -A POSTROUTING -d %s -j MARK --set-mark %d',  $subnet, $parent_handle );
    $qd->run( sprintf 'iptables -t mangle -A POSTROUTING -d %s -j RETURN', $subnet);
}

for my $group_name ( keys %devices ) {

    say "# $group_name -- queue download speed $devices{ $group_name }->{ download_speed } upload speed $devices{ $group_name }->{ upload_speed }";

    my $download_queue = NC::TC::Queue->new(
        device       => $qd->device,
        id           => $qd->handle . $qd->next_queue_id,
        priority     => $devices{ $group_name }->{ priority },
        parent       => $parent_queue->id,
        rate         => $devices{ $group_name }->{ download_speed },
        ceiling      => $devices{ $group_name }->{ download_speed },
    )->create;

    my $upload_queue_id = $qd->next_queue_id;

    my $upload_queue = NC::TC::Queue->new(
        device       => $qd->device,
        id           => $qd->handle . $upload_queue_id,
        priority     => $devices{ $group_name }->{ priority },
        parent       => $parent_queue->id,
        rate         => $devices{ $group_name }->{ upload_speed },
        ceiling      => $devices{ $group_name }->{ upload_speed },
    )->create;

    for my $device_ref ( @{ $devices{ $group_name }->{ devices } } ) {

        say "#--- $device_ref->{ desc } download speed $device_ref->{ download_speed } upload speed $device_ref->{ upload_speed }";
        my $device = NC::Device->new(
            hostname  => $device_ref->{ hostname },
            ipaddr    => $device_ref->{ ipaddr },
            desc      => $device_ref->{ desc },
            priority  => $device_ref->{ priority },
            download_queue => NC::TC::Queue->new(
                device       => $qd->device,
                id           => $qd->handle. $qd->next_queue_id,
                priority     => $device_ref->{ priority },
                parent       => $download_queue->id,
                rate         => $device_ref->{ download_speed },
                ceiling      => $device_ref->{ download_speed },
                mark         => $qd->next_queue_id
            )->create,
            upload_queue => NC::TC::Queue->new(
                lan_subnets  => $local_network{ lan_subnets },
                device       => $qd->device,
                id           => $qd->handle. $qd->next_queue_id,
                priority     => $device_ref->{ priority },
                parent       => $upload_queue->id,
                rate         => $device_ref->{ upload_speed },
                ceiling      => $device_ref->{ upload_speed },
                mark         => $qd->next_queue_id,
            )->create,
        )->create;
    }

    print "\n";
}
