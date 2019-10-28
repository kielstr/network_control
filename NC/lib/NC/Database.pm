package NC::Database;

use 5.20.0;
use Moo;
use Function::Parameters qw/:strict/;
use Data::Dumper::Concise;

use FindBin '$RealBin';
use lib $RealBin . '/../../webapp/NetworkManagement/lib/';

use NetworkManagement::Schema;

has dsn => (
    is => 'ro',
    default => 'dbi:mysql:database=network_management:host=namik;port=3306',
);

has username => (
    is => 'ro',
    default => 'kiel',
);

has password => (
    is => 'ro',
    default => 'Q4*b2&3iWUyg',
);

method connect () {

    $self = __PACKAGE__->new
        unless ref $self eq __PACKAGE__;

    state $schema = NetworkManagement::Schema->connect(
        $self->dsn,
        $self->username,
        $self->password,
    );

    return $schema;
}

1;