package MonkeyMachine;
require Curses::UI;
require XML::Simple;
require Exporter;

our @ISA       = qw( Exporter );
our @EXPORT    = qw( run_machine creat_app focus_win );
our @EXPORT_OK = qw( add_element add_windows set_bindings add_sub_table );
our $VERSION   = 0.01;

use strict;
use warnings;

use Curses::UI;
use Data::Dumper;

sub add_buttonbox {
   my ($win, $opts) = @_;
   my @buttons = ();
   my %args = ();
   my $i = 0;
   foreach my $key (sort(keys %{$opts})) {
      my $value = $opts->{$key};
      if( $key =~ /button/ ){
         push @buttons, { -label => $value->{'label'},
                      -onpress => $value->{'sub'}
         }; 
      }       
      else {
         $args{"-".$key} = $value;
      }
   }
   $args{'-buttons'} = \@buttons;
   $win->add( 
         "button_$i", 'Buttonbox',
         %args
   );
   $i++;
 }

sub add_label {
   my ($win, $opts) = @_;
   my %args = ();
   my $name = undef;
   my $i = 0;
   if( ref($opts) eq "ARRAY") { 
      foreach my $cur (@{$opts}) {
         while( my ($key, $value) = each %{$cur} ) {
            if( $key eq 'title'){ $name = $value;}
            else { 
               $args{"-".$key} = $value;
            }
         }
         #if( !defined $name ) { $name = "sublabel_$i"; $i++;}
         $win->add( $name, 'Label', %args );
         $name = undef;
      } 
   } 
   else {
      while( my ($key, $value) = each %{$opts}) {
         if( $key eq 'title') { $name = $value;}
         else { 
            $args{"-".$key} = $value;
         }
      }

      #if( !defined $name ) { $name = "label_$i"; $i++;}
      $win->add( 
        $name, 'Label',
        %args
      );
   }
}

sub add_listbox {
   my ($win, $opts) = @_;
   my %args = ();
   my @values = ();
   my %labels = ();
   my $name = undef; 
   while( my ($key, $value) = each %{$opts}) {
      if( $key eq 'labels' ) {
         my $i = 0;
         if( ref($value->{'tag'}) eq 'ARRAY') {
            %labels = map {$_ => $value->{'tag'}[$_]} 0..$#{$value->{'tag'}};  
            @values = keys %labels;
         }
         else {
            %labels = map {$_ => $value->{'tag'} } 0; 
            @values = keys %labels
         }
         $args{'-labels'} = \%labels;
         $args{'-values'} = \@values;
      }
      elsif( $key eq 'title') {
         $name = $key;   
      }
      else {
         $args{"-".$key} = $value;
      }
   }
   $win->add( 
      $name, 'Listbox',
      %args
   );
}

my %sub_els_table = (
   'label' => \&add_label,
   'buttonbox' => \&add_buttonbox,
   'listbox' => \&add_listbox
);

sub creat_app {
   my ( $opts ) = $_[1];
   my $UI = new Curses::UI( %{$opts});
   return $UI;
}
sub add_windows {
   my ($class, $UI, $screens, $args ) = @_;
   my %win = (); 
   while (my ($scene, $title) = each %{$screens} ) {
      $win{$scene} = $UI->add(
         "win_$scene", 'Window', 
         -title => $title,  
         %{$args}
      );
   }
   return \%win;
}

sub add_element {
   my ( $class, $win, $scene ) = @_;
   while(( my ($key, $value ) = each %{$scene} )) {
         $sub_els_table{$key}->( $win, $value ) if exists $sub_els_table{$key}
            or die "Error in subroutine: add_element"; 
   }
}

sub add_sub_table {
   my ($class, $script, $sub_table ) = @_;
   my $FD;
   while(( my( $key, $value ) = each %{$sub_table} )) {
      my @tags = split(':', $key); 
      my $win = shift(@tags); 
      my $scene = $script->{'scene'}[$win];
      foreach my $tag (0..$#tags-1) {
         $scene = $scene->{$tags[$tag]}; 
      }
      $scene->{$tags[-1]} = $value; 
   }
   return $script;
}

sub focus_win {
   my ($class, $win, $scene ) = @_;
   $win->{$scene}->focus;
}

sub set_bindings {
   my ($class, $UI, $bindings_table) = @_;
   while( my ( $key, $value ) = each %{$bindings_table}) {
      $UI->set_binding( $value, $key);
   }
}

sub run_machine {
   my ($class, $UI ) = @_;
   $UI->mainloop if( defined $UI) or die "Error in subroutine: run_machine.";
}
1;
