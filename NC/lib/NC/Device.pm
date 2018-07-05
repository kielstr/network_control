package NC::Device;

use 5.20.0;
use Moo;
use Data::Dumper::Concise;
use Function::Parameters qw/:strict/;

extends 'NC';

has hostname  => ( is => 'ro' );
has ipaddr    => ( is => 'ro' );
has desc      => ( is => 'ro' );
has mark      => ( is => 'ro' );
has upload_queue => ( is => 'ro' );
has download_queue => ( is => 'ro' );
has priority => ( is => 'ro' );

method create () {
    $self->download_queue_rule->upload_queue_rule;
    return $self;
}

method upload_queue_rule () {
    my $cmd = sprintf 'tc filter add dev %s parent 1:0 protocol ip prio %d handle %d fw classid %s',
        $self->upload_queue->device, 
        $self->priority,
        $self->upload_queue->mark, 
        $self->upload_queue->id;

    $self->run( $cmd );

    for my $subnet ( @{ $self->upload_queue->lan_subnets } ) {
        # Was PREROUTING
        
        $cmd = sprintf 'iptables -t mangle -A PREROUTING -s %s ! -d %s -j MARK --set-mark %d', 
            $self->hostname, 
            $subnet, 
            $self->upload_queue->mark;

        $self->run( $cmd );

        $cmd = sprintf 'iptables -t mangle -A PREROUTING -s %s ! -d %s -j RETURN',
            $self->hostname,
            $subnet;

        $self->run( $cmd );
    }

    return $self; 
    
}

method download_queue_rule () {

    my $cmd = sprintf 'tc filter add dev %s parent 1:0 protocol ip prio %d handle %d fw classid %s', 
        $self->upload_queue->device,
        $self->priority,
        $self->download_queue->mark, 
        $self->download_queue->id;

    $self->run( $cmd );

    for my $subnet ( @{ $self->upload_queue->lan_subnets } ) {
        # Was POSTROUTING

        $cmd = sprintf "iptables -t mangle -A POSTROUTING -d %s ! -s %s -j MARK --set-mark %d", 
            $self->hostname,
            $subnet,
            $self->download_queue->mark;

        $self->run( $cmd );

        $cmd = sprintf "iptables -t mangle -A POSTROUTING -d %s ! -s %s -j RETURN", $self->hostname, $subnet;
        $self->run( $cmd );
    }

    return $self; 
}

1;
