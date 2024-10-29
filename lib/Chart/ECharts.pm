package Chart::ECharts;

use feature ':5.10';
use strict;
use utf8;
use warnings;

use JSON::PP       ();
use Digest::SHA    qw(sha1_hex);
use File::ShareDir qw(dist_file);
use File::Spec;
use IPC::Open3;
use File::Basename;

our $VERSION = '0.09_1';
$VERSION =~ tr/_//d;    ## no critic

use constant DEBUG => $ENV{ECHARTS_DEBUG} || 0;

sub new {

    my $class = shift;

    my %params = (
        theme            => 'white',
        responsive       => 0,
        class            => 'chart-container',
        styles           => ['min-width:auto', 'min-height:300px'],
        chart_prefix     => 'chart_',
        option_prefix    => 'option_',
        container_prefix => 'id_',
        events           => {},
        renderer         => 'canvas',
        vertical         => 0,
        locale           => 'en',
        options          => {},
        toolbox          => [],
        width            => undef,
        height           => undef,
        xAxis            => [],
        yAxis            => [],
        series           => [],
        events           => {},
        id               => get_random_id(),
        @_
    );

    my $self = {%params};

    return bless $self, $class;

}

sub chart_id { shift->{id} }

sub set_option {
    my ($self, $options) = @_;
    $self->{options} = $options;
}

sub set_option_item {
    my ($self, $name, $params) = @_;
    $self->{options}->{$name} = $params;
}

sub get_random_id {
    return sha1_hex(join('', time, rand));
}

sub set_event {
    my ($self, $event, $callback) = @_;
    $self->{events}->{$event} = $callback;
}

sub on { shift->set_event(@_) }

sub add_xAxis {
    my ($self, $axis) = @_;
    push @{$self->{xAxis}}, $axis;
}

sub add_yAxis {
    my ($self, $axis) = @_;
    push @{$self->{yAxis}}, $axis;
}

sub add_series {
    my ($self, $series) = @_;
    push @{$self->{series}}, $series;
}

sub xAxis  { shift->{xAxis} }
sub yAxis  { shift->{yAxis} }
sub series { shift->{series} }

sub default_options { {} }

sub options {

    my ($self) = @_;

    my $default_options = $self->default_options;
    my $global_options  = $self->{options};

    my $default_series_options = delete $default_options->{series} || {};
    my $series_options         = delete $global_options->{series}  || {};

    my $options = {series => $self->series};

    for (my $i = 0; $i < @{$options->{series}}; $i++) {
        $options->{series}->[$i] = {%{$options->{series}->[$i]}, %{$default_series_options}};
        $options->{series}->[$i] = {%{$options->{series}->[$i]}, %{$series_options}};
    }

    $options = {%{$options}, %{$self->axies}, %{$default_options}, %{$global_options}};

    return $options;

}

sub axies {

    my ($self) = @_;

    if ($self->{vertical}) {
        return {xAxis => $self->{yAxis}, yAxis => $self->{xAxis}};
    }

    return {xAxis => $self->{xAxis}, yAxis => $self->{yAxis}};

}

sub render_script {

    my ($self, %params) = @_;

    my $chart_id = $self->{id};
    my $theme    = $self->{theme};
    my $renderer = $self->{renderer};
    my $wrap     = $params{wrap} //= 0;

    my $json = JSON::PP->new;

    $json->utf8->canonical->allow_nonref->allow_unknown->allow_blessed->convert_blessed->escape_slash(0);

    my $option = $json->encode($self->options);

    my @script = ();

    my $locale       = $self->{locale};
    my $chart        = join '', $self->{chart_prefix},     $chart_id;
    my $opt          = join '', $self->{option_prefix},    $chart_id;
    my $container    = join '', $self->{container_prefix}, $chart_id;
    my $init_options = $json->encode({locale => $locale, renderer => $renderer});

    push @script, qq{let $chart = echarts.init(document.getElementById('$container'), '$theme', $init_options);};
    push @script, qq{let $opt = $option;};
    push @script, qq{$opt && $chart.setOption($opt);};

    foreach my $event (keys %{$self->{events}}) {
        my $callback = $self->{events}->{$event};
        push @script, qq{$chart.on('$event', function (params) { $callback });};
    }

    if ($self->{responsive}) {
        push @script, qq{window.addEventListener('resize', function () { chart_$chart_id.resize() });};
    }

    my $script = join "\n", @script;

    return "<script>\n$script\n</script>" if $wrap;

    return $script;

}

sub render_html {

    my ($self) = @_;

    my $style  = '';
    my @styles = @{$self->{styles}};

    push @styles, sprintf('width:%s',  $self->{width})  if ($self->{width});
    push @styles, sprintf('height:%s', $self->{height}) if ($self->{height});

    my $script = $self->render_script(wrap => 1);

    my $chart_id        = $self->{id};
    my $container_id    = join '',  $self->{container_prefix}, $chart_id;
    my $styles          = join ';', @styles, $style;
    my $class_container = $self->{class};

    my $html = qq{<div id="$container_id" class="$class_container" style="$styles"></div>\n$script};

    return $html;

}

sub render_image {

    my ($self, %params) = @_;

    my $render_script = dist_file('Chart-ECharts', 'render.cjs');

    my $node_path = delete $params{node_path};
    my $node_bin  = delete $params{node_bin} || '/usr/bin/node';
    my $output    = delete $params{output}   || Carp::croak 'Specify "output" file';
    my $format    = delete $params{format};
    my $width     = delete $params{width};
    my $height    = delete $params{height};
    my $option    = JSON::PP->new->encode($self->options);

    if (!$format) {

        my ($file, $dir, $suffix) = fileparse($output, ('.png', ',svg'));

        Carp::croak 'Unsupported output "format"' unless $suffix;

        ($format = $suffix) =~ s/\.//;

    }

    if ($format ne 'png' && $format ne 'svg') {
        Carp::croak 'Unknown output "format"';
    }

    if ($node_bin !~ /(node|node.exe)$/i) {
        Carp::croak 'Unknown node command';
    }

    if (!-e $node_bin && !-x _) {
        Carp::croak 'Node binary not found';
    }

    local $ENV{NODE_PATH} //= $node_path if $node_path;

    my @cmd = ($node_bin, $render_script, '--output', $output, '--format', $format, '--option', $option);

    push @cmd, '--width',  $width  if ($width);
    push @cmd, '--height', $height if ($height);

    DEBUG and say STDERR sprintf('Command: %s', join ' ', @cmd);

    my $pid = open3(my $stdin, my $stdout, my $stderr, @cmd);

    waitpid($pid, 0);
    my $exit_status = $? >> 8;

    if (DEBUG) {

        say STDERR "Enviroment Variables:";
        say STDERR sprintf("NODE_PATH=%s\n", $ENV{NODE_PATH} || '');

        if ($stderr) {
            say STDERR 'Command STDERR:';
            say STDERR <$stderr>;
        }

        if ($stdout) {
            say STDERR 'Command STDOUT:';
            say STDERR <$stdout>;
        }

        say STDERR "Command exit status: $exit_status";

    }


}

sub TO_JSON { shift->options }

1;
