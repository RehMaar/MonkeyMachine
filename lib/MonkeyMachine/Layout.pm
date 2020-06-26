package MonkeyMachine::Layout;
use strict;
use warnings;

use Data::Dumper;

#TODO: To know more about Exporter. 
use Exporter;
use vars qw( $VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

$VERSION       = 0.0001;
@ISA           = qw( Exporter );
@EXPORT        = ();
@EXPORT_OK     = qw( new eval_params );
%EXPORT_TAGS   = ( DEFAULT => [qw( &new &eval_params )]);

sub new {
   die "Check your constructor, monkey.\n$!" if ( scalar(@_) < 3);
   my $class = shift;
   my $self = {
      rows => shift,
      cols => shift
   };
   die "Wrong argument! More then zero!\n$!" if( $self->{rows} == 0 or $self->{cols} == 0 );
   bless $self, $class;
   return $self;
}

sub eval_params {
   die "Check your args in eval_params sub, monkey.\n$1" if(scalar(@_) != 7);
   my ($self, $mheight, $mwidth, $rowb, $rowe, $colb, $cole)  = @_;
   my $x = ($colb*$mwidth/$self->{cols})+1;
   my $y = ($rowb*$mheight/$self->{rows})+1;
   my $width = ($mwidth/$self->{cols})*($cole-$colb+1);
   my $height = ($mheight/$self->{rows})*($rowe-$rowb+1);
   return { x => $x, y => $y, width => $width, height => $height };
}
1;
