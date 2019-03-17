package Services::Response;

use warnings;
use strict;
use Data::Dumper;


sub new {
    my( $class, $args ) = @_;

    my $self = {
        error => $args->{error},
        data => $args->{data},
    };

    bless $self, $class;
    return $self;
}

sub error {
    my( $self, $error_str ) = @_;

    $self->{error} = $error_str if $error_str;

    return $self->{error};
}

sub data {
    my( $self, $data ) = @_;
    
    $self->{data} = $data if $data;
    
    return $self->{data};
}

1;
