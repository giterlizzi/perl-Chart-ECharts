package Chart::ECharts::StackedBar;

use feature ':5.10';
use strict;
use utf8;
use warnings;

use base 'Chart::ECharts::Bar';

sub default_options { {series => {stack => {}}} }

1;
