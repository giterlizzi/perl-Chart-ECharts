package Chart::ECharts::Base;

use feature ':5.10';
use strict;
use utf8;
use warnings;

use Carp ();
use base 'Chart::ECharts';

sub type { Carp::croak 'Unknown chart type' }

sub default_options { {tooltip => {trigger => 'axis'}} }

sub build_series {

    my ($self, $data) = @_;

    if (ref($data) eq 'HASH') {
        $data = [map { {name => $_, value => $data->{$_}} } sort keys %{$data}];
    }

    return {type => $self->type, data => $data};

}

sub category {

    my ($self, $data) = @_;

    $self->add_xAxis({type => 'category', data => $data});
    $self->add_yAxis({type => 'value'});

}

sub data {

    my ($self, @args) = @_;

    my ($name, $data, $options) = @args;
    $options //= {};

    my $series = $self->build_series($data);

    $series->{name} = $name;
    $series = {%{$series}, %{$options}};

    $self->add_series($series);
    return $self;

}

1;
