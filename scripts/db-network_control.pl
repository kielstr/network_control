#!/usr/bin/env perl

use 5.20.0;
use strict;
use warnings;
use Data::Dumper::Concise;

use FindBin '$RealBin';
use lib "$RealBin/../NC/lib", "$RealBin/../webapp/NetworkManagement/lib/";
use Cpanel::JSON::XS;
use YAML::Tiny;
use NC::Database;
use NC::TC::Qdisc;
use NC::TC::Queue;
use NC::Device;

my $schema = NC::Database->connect();

unless ( @ARGV and $ARGV[0] eq '-f' ) {

    my $count = $schema->resultset('Device')->search(
        { 'dt' => \"> (SELECT network_control_last_run FROM config)" } 
    )->count || $schema->resultset('User')->search(
        { 'dt' => \"> (SELECT network_control_last_run FROM config)" } 
    )->count;

    exit if $count == 0;
}

my $conf_rs = $schema->resultset('Config')->next;

$NC::Verbose = 0;
$NC::DryRun = 0;

my $qd = NC::TC::Qdisc->new( 
    handle => '1:', 
    device => $conf_rs->device, 
    default => 1 )
->clear
->create;

# Clear NAT 
$qd->run( 'iptables -t nat -F' );

# Clear marking rules
$qd->run( 'iptables -t mangle -F' );

# Clear chains
$qd->run( 'iptables -F' );

# Allow ssh hosts
$qd->run( 'iptables -A INPUT -p tcp -s portal.sdlocal.net --dport 22 -j ACCEPT' );
$qd->run( 'iptables -A INPUT -p tcp -s 60.241.110.238 --dport 22 -j ACCEPT' );
$qd->run( 'iptables -A INPUT -p tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT' );
$qd->run( 'iptables -A INPUT -p tcp --dport 22 -j DROP' );

my $parent_handle = $qd->next_queue_id;

my $parent_queue = NC::TC::Queue->new(
    device       => $qd->device,
    id           => $qd->handle . $parent_handle,
    priority     => 1,
    parent       => $qd->handle,
    rate         => '1000mbit',
    ceiling      => '1000mbit',
)->create;

$qd->run(sprintf 'tc filter add dev %s parent 1:0 protocol ip prio 1 handle %s fw classid %s', 
    $conf_rs->device,
    $qd->next_queue_id,
    $qd->handle . $qd->next_queue_id,
);

# Masquerade for local networks.
for my $subnet ( @{ decode_json $conf_rs->masquerade} ) {
    $qd->run(sprintf 'iptables -t nat -A POSTROUTING -s %s -o %s -j SNAT --to-source %s', $subnet, $conf_rs->device,  $conf_rs->gateway);
}

my $users_rs = $schema->resultset('User');

while(my $user = $users_rs->next) {

    next unless $user->active;
    say $user->firstname;

    say "# " . $user->firstname . " -- queue download speed " . $user->download_speed . " upload speed " . $user->upload_speed;

    my $download_queue = NC::TC::Queue->new(
        device       => $qd->device,
        id           => $qd->handle . $qd->next_queue_id,
        priority     => $user->priority,
        parent       => $parent_queue->id,
        rate         => $user->download_speed,
        ceiling      => $user->download_speed,
    )->create;

    my $upload_queue_id = $qd->next_queue_id;

    my $upload_queue = NC::TC::Queue->new(
        device       => $qd->device,
        id           => $qd->handle . $upload_queue_id,
        priority     => $user->priority,
        parent       => $parent_queue->id,
        rate         => $user->upload_speed,
        ceiling      => $user->upload_speed,
    )->create;

    for my $device ( $user->devices ) {
        
        say "#--- " . $device->description . " download speed " . $device->download_speed . " upload speed " . $device->upload_speed;

        NC::Device->new(
            hostname  => $device->hostname,
            ipaddr    => $device->ip,
            desc      => $device->description,
            priority  => $device->priority,
            download_queue => NC::TC::Queue->new(
                device       => $qd->device,
                id           => $qd->handle. $qd->next_queue_id,
                priority     => $device->priority,
                parent       => $download_queue->id,
                rate         => $device->download_speed,
                ceiling      => $device->download_speed,
                mark         => $qd->next_queue_id
            )->create,
            upload_queue => NC::TC::Queue->new(
                lan_subnets  => decode_json($conf_rs->lan_subnets),
                device       => $qd->device,
                id           => $qd->handle. $qd->next_queue_id,
                priority     => $device->priority,
                parent       => $upload_queue->id,
                rate         => $device->upload_speed,
                ceiling      => $device->upload_speed,
                mark         => $qd->next_queue_id,
            )->create,
        )->create;  
    };
    print "\n";
}

$conf_rs->update({ network_control_last_run => \"now()" });
