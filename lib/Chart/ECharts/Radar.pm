package Chart::ECharts::Radar;

use feature ':5.10';
use strict;
use utf8;
use warnings;

use base 'Chart::ECharts::Base';

sub type {'radar'}

sub indicator {

    my ($self, $data) = @_;

    if (!defined($self->{options}->{radar})) {
        $self->{options}->{radar}->{indicator} = [];
    }

    foreach (@{$data}) {

        if (ref($_) eq 'HASH') {
            push @{$self->{options}->{radar}->{indicator}}, $_;
        }
        else {
            push @{$self->{options}->{radar}->{indicator}}, {min => 0, name => $_};
        }

    }

}

sub data {

    my ($self, %data) = @_;

    if (!@{$self->{series}}) {
        push @{$self->{series}}, {type => $self->type, data => []};
    }

    foreach my $name (sort keys %data) {
        push @{$self->{series}->[0]->{data}}, {name => $name, value => $data{$name}};
    }

}

1;
