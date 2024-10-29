package Chart::ECharts::Pie;

use feature ':5.10';
use strict;
use utf8;
use warnings;

use base 'Chart::ECharts::Base';

sub type {'pie'}

sub default_options { {
    tooltip  => {trigger   => 'item'},
    emphasis => {itemStyle => {shadowBlur => 10, shadowOffsetX => 0, shadowColor => 'rgba(0, 0, 0, 0.5)'}}
} }

1;
