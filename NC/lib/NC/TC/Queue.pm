package NC::TC::Queue;

use 5.20.0;

use Moo;
use Function::Parameters qw/:strict/;

extends 'NC';

has id => ( is => 'ro', );
has priority => ( is => 'ro', required => 1, );
has rate => ( is => 'ro', required => 1, );
has ceiling => ( is => 'ro', required => 1, );
has parent => ( is => 'ro', required => 1, ); 
has devices => ( is => 'ro', required => 0, );
has device => ( is => 'ro', required => 1, );
has lan_subnets => ( is => 'ro' );
has mark => ( is => 'ro' );

method create () {
    my $cmd = sprintf "tc class add dev %s parent %s classid %s htb rate %s ceil %s",
                $self->device,
                $self->parent,
                $self->id,
                $self->rate,
                $self->ceiling;
                
    $self->run( $cmd );

    return $self;
}

1;