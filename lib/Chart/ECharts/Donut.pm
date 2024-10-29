package Chart::ECharts::Donut;

use feature ':5.10';
use strict;
use utf8;
use warnings;

use base 'Chart::ECharts::Pie';

sub default_options { {
    tooltip  => {trigger   => 'item'},
    series   => {radius    => ['40%', '70%']},
    emphasis => {itemStyle => {shadowBlur => 10, shadowOffsetX => 0, shadowColor => 'rgba(0, 0, 0, 0.5)'}}
} }

1;