#!/usr/bin/perl
# Time-stamp: "1998-08-10 00:08:26 MDT"
use MIDI;
use Getopt::Std;

getopts('E:I:btfd');
 # b = brief (don't dump the tracks)
 # f = flat (not brief)
 # d = data (don't parse the MTrk track data)
 # t = only read in the text events
 # I [comma-separated list] = include only given events
 # E [comma-separated list] = exclude given events

die "Don't specify both -I and -E!\n" if length($opt_I) and length($opt_E);
@Include = grep(m/\w/, split(',', $opt_I ));
@Exclude = grep(m/\w/, split(',', $opt_E ));
@Include = @MIDI::Event::Text_events if $opt_t; # shortcut for text only 
die "No filename" unless @ARGV;

print "# Reading $ARGV[0]\n" unless $opt_b;
$opus = MIDI::Opus->new({'from_file' => $ARGV[0], 'no_parse' => ($opt_d),
 @Include ? ( 'include' => \@Include) : (),
 @Exclude ? ( 'exclude' => \@Exclude) : (), } );
$opus->dump( { 'dump_tracks' => !$opt_b, 'flat' => $opt_f } );
print "# OK at ", scalar(localtime), ".\n" unless $opt_b;
exit;
