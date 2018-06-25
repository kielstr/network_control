package NC::TC::Qdisc;

use 5.20.0;
use Moo;
use Function::Parameters qw/:strict/;
use Data::Dumper::Concise;

has handle  => ( is => 'ro' );
has device => ( is => 'ro' );
has default => ( is => 'ro' );

extends 'NC';

method create () {
    my $cmd = sprintf "tc qdisc add dev %s root handle %s htb default %s", 
        $self->device,
        $self->handle,
        $self->default;

    $self->run( $cmd );

    return $self;
}

method clear () {
    my $cmd =  sprintf 'tc qdisc del dev %s root', $self->device;

    $self->run( $cmd, { non_fatal => 1 });

    return $self;
}

method next_queue_id () {

    state $highest_id;

    my $device = $self->device;

    my @taken_ids = sort { 
        my $a_id = ( split ':', $a )[1];
        my $b_id = ( split ':', $b )[1];
        $a_id<=> $b_id 
    } map { (split /\s/, $_)[2] } split /\n/, `tc class show dev $device`;
    
    $highest_id = @taken_ids ? ( split ':', pop @taken_ids )[1] : 0;

    return ++$highest_id;
}

1;