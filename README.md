[![Release](https://img.shields.io/github/release/giterlizzi/perl-Chart-ECharts.svg)](https://github.com/giterlizzi/perl-Chart-ECharts/releases) [![Actions Status](https://github.com/giterlizzi/perl-Chart-ECharts/workflows/linux/badge.svg)](https://github.com/giterlizzi/perl-Chart-ECharts/actions) [![License](https://img.shields.io/github/license/giterlizzi/perl-Chart-ECharts.svg)](https://github.com/giterlizzi/perl-Chart-ECharts) [![Starts](https://img.shields.io/github/stars/giterlizzi/perl-Chart-ECharts.svg)](https://github.com/giterlizzi/perl-Chart-ECharts) [![Forks](https://img.shields.io/github/forks/giterlizzi/perl-Chart-ECharts.svg)](https://github.com/giterlizzi/perl-Chart-ECharts) [![Issues](https://img.shields.io/github/issues/giterlizzi/perl-Chart-ECharts.svg)](https://github.com/giterlizzi/perl-Chart-ECharts/issues) [![Coverage Status](https://coveralls.io/repos/github/giterlizzi/perl-Chart-ECharts/badge.svg)](https://coveralls.io/github/giterlizzi/perl-Chart-ECharts)

# Chart::ECharts - Apache ECharts for Perl

## Synopsis

```.pl
use Chart::ECharts;

my $chart = Chart::ECharts->new();

$chart->add_xAxis({type => 'category', data => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']});
$chart->add_yAxis({type => 'value'});
$chart->add_series({name => 'series_name', type => 'bar', data => [120, 200, 150, 80, 70, 110, 130]});

# Render in HTML
$chart->render_html;

# Render chart in image
$chart->render_image(output => '/my-path/cool-chart.png', width => 600, height => 800);
```

## Install

Using Makefile.PL:

To install `Chart::ECharts` distribution, run the following commands.

    perl Makefile.PL
    make
    make test
    make install

Using App::cpanminus:

    cpanm Chart::ECharts


## Documentation

 - https://metacpan.org/release/Chart-ECharts


## Copyright

 - Copyright 2024 © Giuseppe Di Terlizzi
