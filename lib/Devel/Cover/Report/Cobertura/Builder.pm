package Devel::Cover::Report::Cobertura::Builder;
use Template;
use File::Basename qw(dirname);
use Devel::Cover::Report::Cobertura;
use Devel::Cover::Report::Clover::Project;
use Devel::Cover::Report::Clover::FileRegistry;
use strict;
use warnings;

our $VERSION = "1.01";

use base qw(Devel::Cover::Report::Clover::Builder);
__PACKAGE__->mk_ro_accessors(qw(db));
__PACKAGE__->mk_accessors(qw(name file_registry project include_condition_criteria ));

sub new {
    my $class = shift;

    my $self = $class->SUPER::new(@_);

    return $self;
}

sub generate {
    my ( $self, $outfile ) = @_;

    my $xml = $self->report_xml();

    die("undef is a terrible file name") if !defined $outfile;

    open( my $fh, '>', $outfile ) or die($!);
    print {$fh} $xml;
    close($fh);

    return $xml;

}

sub report {
    my ($self) = @_;
    my $data = {
        project      => $self->project->report(),
        generated    => time(),
        generated_by => 'Devel::Cover::Report::Cobertura',
        version      => $Devel::Cover::Report::Cobertura::VERSION,
    };
    return $data;
}

sub report_xml {
    my ($self) = @_;

    my $tt = Template->new( { INCLUDE_PATH => $self->template_dir, } );

    my $out  = '';
    my $vars = $self->report();

    $tt->process( $self->template_file, $vars, \$out ) || die $tt->error();
    return $out;

}

sub accept_criteria {
    return qw( statement branch condition subroutine );
}

sub template_file {
    'cobertura.tt';
}

sub template_dir {
    sprintf( '%s', dirname(__FILE__) );
}

1;

