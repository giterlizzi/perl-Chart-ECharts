package Chart::ECharts::Parallel;

use feature ':5.10';
use strict;
use utf8;
use warnings;

use base 'Chart::ECharts::Base';

sub type {'parallel'}

sub default_options { {series => {lineStyle => {width => 2}}} }

1;
