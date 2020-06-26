#!/bin/perl

use strict;
use warnings;

use lib './lib';
use MonkeyMachine::Config;
use MonkeyMachine;
#------------------------------------------------------------------------------
#  Read user config.
#------------------------------------------------------------------------------

my $user_config = MonkeyMachine::Config->ini_read('config.ini');

#------------------------------------------------------------------------------
#  Person.
#------------------------------------------------------------------------------

my $username = undef;

#------------------------------------------------------------------------------
#  Game *logic*.
#------------------------------------------------------------------------------

my $health;
my $score;
my $stamina;

sub set_stat_default{
   $health = 100;
   $stamina = 100;
   $score = 0;
}

#------------------------------------------------------------------------------
#  Game script. 
#------------------------------------------------------------------------------

my $script = MonkeyMachine::Config->xml_read( 'config.xml' );
#MonkeyMachine::Config->test_struct('tmp_list', $script);

#------------------------------------------------------------------------------
# Initialize windows.   
#------------------------------------------------------------------------------
my $UI =  MonkeyMachine->creat_app( 
   { -clear_on_exit => 1 }
); 

my %bindings_table = (
   "\cQ" => sub{ exit(0);}, 
   "\cX" => sub{ show_scene('0'); }
);
MonkeyMachine->set_bindings($UI, \%bindings_table );

my $title = "The Dungeon of the Dragon";
my %screens = ( 
   '0' => $title,
   '1' => $title,
   '2' => $title,
   '3' => $title,
   '4' => $title,
   '5' => $title,
   '6' => $title,
   '7' => $title,
   '8' => $title,
   '9' => $title,
   '10' => $title,
   '11' => $title,
   '12' => 'Финальный счёт',
   '13' => 'Статистика'
);

my %args_main = ( 
   -border => 1,
   -padtop       => 1, 
   -padbottom    => 1, 
   -ipad         => 1
);
my $win = MonkeyMachine->add_windows( $UI, \%screens, \%args_main );

#------------------------------------------------------------------------------
# Subroutines.  
#------------------------------------------------------------------------------

sub show_scene {
  my ($scene ) = @_;
  MonkeyMachine->focus_win( $win, $scene );
}

sub update_stat {
   my ($name, $h, $s, $r ) = @_;

   if( $user_config ) {
      foreach my $rec (@{$user_config}) {
         if($rec->{'User'}->{'name'} eq $name ) {
            $rec->{'User'}->{'health'} = $h;
            $rec->{'User'}->{'stamina'} = $s;
            $rec->{'User'}->{'score'} = $r;
            return; 
         }    
      }
   }
   push @{$user_config}, { 'User' => { 'name' => $name,
                                       'health' => $h,
                                       'stamina'=> $s,
                                       'score' => $r
                                     }
                         };
}

sub save_stat {
   MonkeyMachine::Config->ini_write( 'config.ini', $user_config);
}

#------------------------------------------------------------------------------
# Add sub to script. 
#------------------------------------------------------------------------------

my %sub_table = ();

#------------------------------------------------------------------------------
#  Scene 0 -- Main
#------------------------------------------------------------------------------

sub scene_0_but_1 {
   my $button = shift;
   set_stat_default();
   $username = $button->root->question( "Введите Ваше имя: " ); 
   show_scene('1');   
}
sub scene_0_but_2 {
   exit(0);
}
sub scene_0_but_3 {
   show_scene('13');
}

$sub_table{'0:buttonbox:button_1:sub'} = \&scene_0_but_1;
$sub_table{'0:buttonbox:button_2:sub'} = \&scene_0_but_2;
$sub_table{'0:buttonbox:button_3:sub'} = \&scene_0_but_3;

#------------------------------------------------------------------------------
#  Scene 1: Вход.
#------------------------------------------------------------------------------
sub scene_1_but_1 {
   $score += 10;   # За храбрость. 
   show_scene('2');
}
sub scene_1_but_2 {
   $health -= 5;
   $score += 15;    # За разумное недоверие. 
   $stamina -= 40; # За холод. 
   show_scene('3');
}
$sub_table{'1:buttonbox:button_1:sub'} = \&scene_1_but_1;
$sub_table{'1:buttonbox:button_2:sub'} = \&scene_1_but_2;

#------------------------------------------------------------------------------
#  Scene 2: Проверить сосуд. Идти с факелом.
#------------------------------------------------------------------------------
sub scene_2_but_1 {
   show_scene('4');
}

$sub_table{'2:buttonbox:button_1:sub'} = \&scene_2_but_1;

#------------------------------------------------------------------------------
#  Scene 3: Коридор без факела.
#------------------------------------------------------------------------------
sub scene_3_but_1 {
   show_scene('5');
}

$sub_table{'3:buttonbox:button_1:sub'} = \&scene_3_but_1;

#------------------------------------------------------------------------------
# Scene 4: Коридор c факелом.
#------------------------------------------------------------------------------
sub scene_4_but_1{ show_scene('5');}
$sub_table{'4:buttonbox:button_1:sub'} = \&scene_4_but_1;

#------------------------------------------------------------------------------
# Scene 5: Первая развилка: дракон vs проход.
#------------------------------------------------------------------------------
sub scene_5_but_1 { 
   $score += 10; # За глупость -40, за храбрость +50.
   $stamina -= 10;  # Очевидная усталость 
   show_scene('6');
}
sub scene_5_but_2 { 
   $score += 20;   # За благоразумие.
   if( $stamina <= 60 ) { 
      show_scene('10');
   }
   else {
      show_scene('11');
   }
}
$sub_table{'5:buttonbox:button_1:sub'} = \&scene_5_but_1;
$sub_table{'5:buttonbox:button_2:sub'} = \&scene_5_but_2;

#------------------------------------------------------------------------------
# Scene 6 
#------------------------------------------------------------------------------
sub scene_6_but_1{ 
   if($stamina < 90 ) {
    $health = 0; # В чертоги Мандоса.
      $score += 2; 
      show_scene('12');
   }
   else {
      show_scene('7');
   }
}
sub scene_6_but_2{ 
         if( $stamina <= 50 ) {
            $health = 0; $score += 1; show_scene('8');
         } else { 
            $score += 10;
            show_scene('8');
         }
}
$sub_table{'6:buttonbox:button_1:sub'} = \&scene_6_but_1;
$sub_table{'6:buttonbox:button_2:sub'} = \&scene_6_but_2;

#------------------------------------------------------------------------------
# Scene 7: Повелитель Драконов
#------------------------------------------------------------------------------

sub scene_7_but_1 {
   $score += 100;
   $stamina -= 10;
   $health -= 20;
   show_scene('12');
}

$sub_table{'7:buttonbox:button_1:sub'} = \&scene_7_but_1;

#------------------------------------------------------------------------------
# Scene 8
#------------------------------------------------------------------------------
sub scene_8_but_1 { 
   show_scene('12');
}
$sub_table{'8:buttonbox:button_1:sub'} = \&scene_8_but_1;

#------------------------------------------------------------------------------
# Scene 9
#------------------------------------------------------------------------------
sub scene_9_but_1 { 
   $score += 20;    # Вы нашли человека. 
   $stamina += 20;  # Со стороны женщина слегка напоминает ту эльфийку. 
   show_scene('12');
}
$sub_table{'9:buttonbox:button_1:sub'} = \&scene_9_but_1;

#------------------------------------------------------------------------------
# Scene 10
#------------------------------------------------------------------------------
sub scene_10_but_1 { 
   $health = 0; # В чертоги Мандоса.  
   $score += 1;  # Разумно распределяйте силы. 
   show_scene('12');
}
$sub_table{'10:buttonbox:button_1:sub'} = \&scene_10_but_1;

#------------------------------------------------------------------------------
# Scene 11
#------------------------------------------------------------------------------
sub scene_11_but_1 { 
   $score += 20; # Вы нашли человека. 
   show_scene('12');
}
$sub_table{'11:buttonbox:button_1:sub'} = \&scene_11_but_1;

#------------------------------------------------------------------------------
#  Scene 12
#------------------------------------------------------------------------------
sub scene_12_but_1 {
   show_scene('0');
}
$win->{'12'}->{'-onfocus'} = sub { 
   my $class = shift;

   my $id1 = $class->getobj('stat_title');
   my $title = $id1->get();
   my $name;
   if($username) {
      $name = $username;
   }
   else {
      $name = 'The Stranger';
   }
   $title =~ s/(?<=of).*/ $name/;
   $id1->text($title);

   my $id2 = $class->getobj('stat');
   my $str = $id2->get();
   $str =~ s/(?<=Health: )\d*(?=\n)/$health/;
   $str =~ s/(?<=Stamina: )\d*(?=\n)/$stamina/; 
   $str =~ s/(?<=Score: )\d*$/$score/; 
   $id2->text($str);

   update_stat( $name, $health, $stamina, $score);    
};
$sub_table{'12:buttonbox:button_1:sub'} = \&scene_12_but_1;

#------------------------------------------------------------------------------
#  Scene 13 -- Settings
#------------------------------------------------------------------------------

sub scene_13_but_2 {
   save_stat();
   show_scene('0');
}
sub scene_13_but_3 {
   $user_config = undef;
   my $class = shift;
   my $id = $class->parent->getobj('stat_table');
   my $text = $id->get();
   my @tmp = split("\n", $text);
   $text =  shift(@tmp) if( @tmp );
   $id->text($text);   
}
sub scene_13_but_1 {
   show_scene('0');
}

$win->{'13'}->{'-onfocus'} = sub {
   if( $user_config ) {
      my $class = shift;
      my $id = $class->getobj('stat_table');
      my $text = $id->get();
      my @tmp = split("\n", $text);
      $text =  shift(@tmp) if( @tmp );
      my @title = ();
      my $nfield = 18; my $ofield = 8;
      foreach my $rec (@{$user_config}) {
         my $n = $rec->{'User'}->{'name'};
         while( length($n) < $nfield) { $n = $n." ";}
         my $h = $rec->{'User'}->{'health'};
         while( length($h) < $ofield) { $h = $h." ";}
         my $s = $rec->{'User'}->{'stamina'};
         while( length($s) < $ofield) { $s = $s." ";}
         my $r = $rec->{'User'}->{'score'};
         push @title, sprintf("%s %s  %s  %s",$n,$h,$s,$r);
      }
      if(@title){ $id->text($text."\n".join("\n", @title));}
   }
};

$sub_table{'13:buttonbox:button_1:sub'} = \&scene_13_but_1;
$sub_table{'13:buttonbox:button_2:sub'} = \&scene_13_but_2;
$sub_table{'13:buttonbox:button_3:sub'} = \&scene_13_but_3;

$script = MonkeyMachine->add_sub_table( $script, \%sub_table);

#------------------------------------------------------------------------------
# Prepare & run the Machine.
#------------------------------------------------------------------------------
while( my ($key, $value) = each %screens){
   MonkeyMachine->add_element( $win->{$key}, $script->{'scene'}[$key] );
}
MonkeyMachine->focus_win( $win, '0');
MonkeyMachine->run_machine($UI);
