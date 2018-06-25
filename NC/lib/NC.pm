package NC;

use 5.20.0;

use Moo;
use Function::Parameters qw/:strict/;
use Capture::Tiny ':all';
use Data::Dumper::Concise;

our $VERSION = "0.01";

our $Verbose = 0;
our $DryRun = 0;

method run ( $cmd, $args = undef) {
    my @caller = caller;

    my ($stdout, $stderr, @result) = capture {
        system $cmd unless $DryRun;
    };

    say "$cmd" if $Verbose;

    unless ( $args->{ non_fatal } ) {
        die "$caller[0]: $caller[1] line $caller[2] -- " . $stderr if $stderr; 
    }   
}



1;
__END__

=encoding utf-8

=head1 NAME

NC - It's new $module

=head1 SYNOPSIS

    use NC;

=head1 DESCRIPTION

NC is ...

=head1 LICENSE

Copyright (C) Kiel.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Kiel E<lt>kielstr@cpan.orgE<gt>

=cut

