package MonkeyMachine::Config;
require XML::Simple;
require Exporter;

our @ISA       = qw( Exporter );
our @EXPORT    = qw( xml_read ini_read ini_write);
our @EXPORT_OK = qw( test_struct );
our $VERSION   = 0.001;

use strict;
use warnings;

use XML::Simple qw( XMLin ); 
use Cwd;
sub xml_read {
   my $filename = $_[1];
   my $scenes = XMLin("$filename");
   return $scenes;
}

use Data::Dumper; 
sub test_struct {
   my $filename = $_[1];
   my $struct  = $_[2];
   open my $FD, '>', $filename;
   print $FD Dumper( $struct );
   close $FD;
} 

## Init-like config parser

sub parse_ini {
   my ($FILE) = shift;
   my @config = (); my $type; my $count = 0;
   while( <$FILE> ){
      next if /^(?:\s+|#)/; 
      chomp;
      if( /^\[(\w+)\]/ ) {
         $type = $1;
         push @config, {"$type" => {}}; #if( keys %hash );
         $count++; 
      }
      else {
         $config[$count-1]->{$type}->{$1}  = $2 if( /\A(\w+)(?>=)'(.+)'\z/)
               or die "Error while parsing config file: $_\n";
      }
   }
   return \@config;
}

sub ini_read {
    my $config_name = $_[1] if( defined $_[0]) 
         or die "Need filename.\n$!";
    open( my $FD, '<', $config_name)
         or return undef;
    my $config = parse_ini( $FD );
    close( $FD );
    return $config;
} 

sub ini_write {
   my $config_name; my $config;
   if( scalar @_ > 2 ) {
      $config_name = $_[1];
      $config = $_[2]; 
   }
   else {
      die " Not valid number of arguments.\n$!";
   }
   open( my $FILE, '+>', $config_name ) 
      or die "Cannot open config file.";   
   if( $config ) {
      foreach my $hash (@{$config}) {
         my ($key, $content) = each %{$hash};
         print $FILE "[$key]\n";
         while( my ( $name, $value ) = each %{$content} ) {
            print $FILE "$name='$value'\n";
         }
      }  
   }
   close $FILE;
}
1;
