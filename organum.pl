#!/usr/local/bin/perl

# use Data::Dumper;
# use MIDI;

require "kirchenmodes.ph";
require "tariffa.ph";
require "lyrics.ph";

my $mi = 5-1;  # forcing lydian
my $ofile = 'o.abp';
my $pi = 0;    # default phrase index (eventually random)
my $ri = 0;    # default rhythm index (eventually random)
my $csn = 4;   # card set number
my $rnd = 0;
my $dir = 'samples/';
my $tripla = 0;
my $tempo = 100;
my $li = -1;
my $fourparts = 0;
my $useBarLines = 0;
my $vleading = 0;  # preserve intervals for voice leading (suggest 2 or 4)
my $voce = 0;

$lastPitchN = 0;
$lastPitchM = 0;

while ($_ = shift) 
{
  if (/^-m/) {
    $mi = (shift) - 1;
  }
  elsif (/^-pi/) {
    $pi = (shift);
    $pi = $pi-1 if length($pi) <= 2;
  }
  elsif (/^-ri/) {
    $ri = (shift);
    $ri = $ri-1 if length($ri) <= 2;
  }
  elsif (/^-li/) {
    $li = (shift) - 1;
  }
  elsif (/^-vl(ead(ing)?)?/) {
    $vleading = (shift);
  }
  elsif (/^-tri/) {
    $tripla = 1;
  }
  elsif (/^-rnd/) {
    $rnd = 1;
  }
  elsif (/^-tempo/) {
    $tempo = shift;
  }
  elsif (/^-bars/) {
    $useBarLines = 1;
  }
  elsif (/^-csn/) {
    $csn = (shift) - 1;
  }
  elsif (/^-o/) {
    $ofile = shift;
    $ofile .= '.abp' if !($ofile =~ /\.abp/);
  }
  elsif (/^-d/) {
    $dir = shift;
    $dir .= "/" if length($dir) > 0 && !($dir =~ m~/$~);
  }
  elsif (/^-voce/) {
    $voce = true;
  }
  elsif (/^-4part/) {
    $fourparts = 1;
  }
  else {
    print "Unknown option: $_\n";
    print <<EOT;
ORGANUM - Jim Bumgardner, data by Athanasius Kircher, via Kaspar Schott
 Options: 
   -li <n>         Lyric number (optional)
   -csn <n>        Card set number (1-6)
   -mi <n>         Mode index (1-8)
   -rnd            Randomize rhythms and phrases
   -pi <n>         Phrase index (1-6)
   -ri <n> n       Rhythm index (varies - typically 1-6 or 1-8)
   -tempo <n>      Tempo in quarter notes per minute (default = 180)
   -tripla         Use triple meter
   -4part          Produce 4-part score (instead of piano style)
   -bars           Use barlines between measures
   -vl <n>         Minimum interval for voice leading (default 0, suggestion: 2 or 4)
   -voce           Produce 4 vocal MIDI files for use with Flinger
   -o filename     Output file prefix
   -d dir          Output directory (default is samples/)
EOT
    exit;
  }
}

printf "LYRIC %s\n", ($li == -1? "none" : $lyrics->[$li]->{title}); 
printf "CARDSET set to %d\n", $csn + 1;
printf "PHRASE set to %d\n", $pi + 1;
printf "RHYTHM set to %d\n", $ri + 1;
printf "RANDOMIZE %s\n", $rnd? "on" : "off";
printf "TRIPLE %s\n", $tripla? "on" : "off";
printf "CARDSET set to %d\n", $csn + 1;
print  "Outputting to $dir$ofile\n";

$title = "Hymnus Automatica";
$title = $lyrics->[$li]->{title} if $li >= 0;


@mEventLists = ([],[],[],[]);  # midi event lists for each voice
@mTimes = (0,0,0,0);           # midi clocks for each voice

foreach my $vn (0..3) {
  push @{$mEventLists[$vn]},['raw_meta_event', 0, 33, "\x00"];
  push @{$mEventLists[$vn]},['control_change', 0, 0, 7, 64];
  push @{$mEventLists[$vn]},['control_change', 0, 0, 1, 50];  # modulation wheel...
}

my $myMode = $modes->[$mi];
my $myKeySig = $myMode->{keysig};
my $myKey = $myMode->{keysig}->{label};
print "Key = $myKey\n";

my $cardset = $cardsets->[$csn];
my $cards = $cardset->{cards};
my $barLength = $tripla? 6 : 4;  # adjust bar length here if a non-duple meter is chosen

$ri = $pi if !(defined  $cardset->{notelengths});  # if using florid counterpoint, must use rhthms that match notes

my @pidxs = ($pi,$pi,$pi,$pi);
my @ridxs = ($ri,$ri,$ri,$ri);


# randomize pitches
if ($rnd) {
  foreach my $i (0..3) {
    my $c = $cards->[$i];
    $pidxs[$i] = int(rand()*scalar(@{$c->{p}}));
    printf "Stroph %d = %d\n", $i+1,$pidxs[$i]+1;
    $ridxs[$i] = $pidxs[$i] if !(defined  $cardset->{notelengths});
  }
}

# randomize rhythms
if ($rnd && defined $cardset->{notelengths})
{
  print "Randomizing phrase rhythms\n";
  foreach my $i (0..3) {
    if ($tripla && defined $cardset->{tripla}) {
      $ridxs[$i] = int(rand()*scalar(@{$cardset->{tripla}}));
    }
    else {
      $ridxs[$i] = int(rand()*scalar(@{$cardset->{notelengths}}));
    }
    printf "Rhythm %d = %d\n", $i+1,$ridxs[$i]+1;
  }
}

# use explicit phrase indices and rhythm indices, if provided 
# as -pi 1234
if (length($pi) > 2) { # phrase indexes specified
  for my $i (0..3) {
    my $ppi = substr($pi,$i,1);
    if ($ppi =~ /[a-z]/i) {
      $ppi = (ord(uc($ppi))-ord('A')) - 1;
    }
    else {
      $ppi = (ord(uc($ppi))-ord('0')) - 1;
    }
    print "Phrase $i = $ppi\n";
    $pidxs[$i] = $ppi;
    $ridxs[$i] = $pidxs[$i] if !(defined  $cardset->{notelengths});
   }
}
if (length($ri) > 2 && defined  $cardset->{notelengths})
{
  for my $i (0..3) {
    $ridxs[$i] = int(substr($ri,$i,1))-1;
   }
}


open (OFILE, ">$dir$ofile") or die ("Can't open %s for output\n");

# %%vocalfont ZapfChancery-MediumItalic 18
my $meter, $metronome;
if ($useBarLines) {
  $meter = $tripla? "3/2" : "C";
}
else {
  $meter = "none";
}

print OFILE <<EOT;
% Music generated by Organum Mathematicum - Athanasius Kircher
% Software by Jim Bumgardner
%
X: 1
%%composerfont ZapfChancery-MediumItalic 18
%%titlefont ZapfChancery-MediumItalic 24
%%partsfont ZapfChancery-MediumItalic 18
T: $title
C: Athanasius Kircher
S: Music generated by Organum Mathematicum - Athanasius Kircher, Software by Jim Bumgardner
M:$meter
#ifdef ABCMIDI
Q:1/4=$tempo
%%XMIDI program 19
#endif
L:1/4
H:The Arca Musurgica is a Music Composition device invented by the Jesuit polymath Athanasius Kircher
H:It is described in his book "Musurgia Universalis", 1650
H:The device generates 4 part polyphonic hymns in a limited variety of meters and modes
H:This file was generated by a software implementation of the Arca by Jim Bumgardner (www.krazydad.com)
H:
EOT

    printf OFILE "H:LYRIC %s\n", ($li == -1? "none" : $lyrics->[$li]->{title}); 
    printf OFILE "H:CARDSET set to %d\n", $csn + 1;
    printf OFILE "H:PHRASE set to %d\n", $pi + 1;
    printf OFILE "H:RHYTHM set to %d\n", $ri + 1;
    printf OFILE "H:RANDOMIZE %s\n", $rnd? "on" : "off";
    printf OFILE "H:TRIPLE %s\n", $tripla? "on" : "off";
    printf OFILE "H:CARDSET set to %d (%s)\n", $csn + 1, $cardset->{title};

print OFILE <<EOT;
O:German/Jesuit
K:$myKey
V:C clef=treble name="Cantus"
V:A clef=treble name="Altus"
V:T clef=bass name="Tenor"
V:B clef=bass name="Bassus"
EOT

if ($fourparts) {
  print OFILE "%%staves [C A T B]\n";
}
else {
  print OFILE "%%staves {(C A) (T B)}\n";
}

# choose phrases and rhythms ahead of time so we can use voices as outer loop

foreach $vn (0..3) 
{
  my $voice = $voices->[$vn];
  printf OFILE "V:%s\n", $voice->{stave};
  foreach $pn (0..3) {  # for each phrase in song
    my $c = $cards->[$pn];
    my $pf = $c->{p}->[$pidxs[$pn]]->[$vn];  # pitch phrase
    # printf("Nbr notes for %s = %d %d %d\n", $voice->{stave}, $#{$pf}, $pidxs[$pn], $vn);
    my $rf;
    if ($tripla && defined $cardset->{tripla})
    {
      if (defined $c->{tripla}) {  # card has override for tripla (Adonic verse in sapphic cards)
        $rf = $c->{tripla}->[$ridxs[$pn]];  # simple style - same rhythm for each voice
      }
      else {
        $rf = $cardset->{tripla}->[$ridxs[$pn]];  # simple style - same rhythm for each voice
      }
    }
    elsif (defined $cardset->{notelengths})
    {
      if (defined $c->{notelengths}) {  # card has override for note lengths (Adonic verse in sapphic cards)
        $rf = $c->{notelengths}->[$ridxs[$pn]];  # simple style - same rhythm for each voice
      }
      else {
        $rf = $cardset->{notelengths}->[$ridxs[$pn]];  # simple style - same rhythm for each voice
      }
    }
    else {
      $rf = $c->{r}->[$ridxs[$pn]]->[$vn];  # rhythm phrase (complex style (classes 3 and 4))
    }

    # Handle leading rests
    my $rOffset = 0;
    my $rDuration = 0;
    $pLength = 0;
    while ($rf->[$rOffset] < 0) 
    {
      printf OFILE 'z%s ', TableToNotelength(-$rf->[$rOffset]);
      $rDuration += abs($rf->[$rOffset]);
      $pLength += abs($rf->[$rOffset]);
      $rOffset++;
      ++$ni;
      if ($pLength >= $barLength) 
      {
          printf OFILE '|' if $useBarLines;
          $pLength -= $barLength;
      }
    }
    # for each note in phrase...
    my %ties = ();
    $lastPitchN = 0;
    
    foreach $ni (0..$#{$pf})
    {
      my $divLength = abs($rf->[$ni+$rOffset]);
      if ($useBarLines) {
        # printf "ni = $ni plength = $pLength divLength = $divLength\n";
        
        if ($pLength + $divLength > $barLength)
        {
          # produce tied note
          printf OFILE '%s%s-|', TableToPitch($vn,$mi,$pf->[$ni]), TableToNotelength($barLength-$pLength);
          printf OFILE '%s%s ', TableToPitch($vn,$mi,$pf->[$ni]), TableToNotelength($pLength+$divLength-$barLength);
          $ties{$ni} = 1;  # keep track of ties for lyrics
          $divLength = $pLength+$divLength-$barLength;
          $pLength = 0;
          # printf("After tie: plength = $pLength divLength = $divLength\n");
        }
        else {
          printf OFILE '%s%s ', TableToPitch($vn,$mi,$pf->[$ni]), TableToNotelength($divLength);
        }
        $pLength += $divLength;
        while ($pLength >= $barLength) {
          printf OFILE '|' if $useBarLines && $ni != $#{$pf};
          $pLength -= $barLength;
        }
      }
      else {
        printf OFILE '%s%s ', TableToPitch($vn,$mi,$pf->[$ni]), TableToNotelength($divLength);
      }
    }
    if ($pn == 3) {
     print OFILE "|]\n";
   }
    else {
      print OFILE "|\n";
    }
    if ($li >= 0 && ($fourparts || $vn == 1)) {
      my $verses = $lyrics->[$li]->{verses};
      # print Dumper($verses)."\n";
      my $verseNo = 1;
      foreach my $verse (@{$verses})
      {
        print OFILE "w:";
        printf OFILE "%d.~", $verseNo if $pn == 0;
        my $lyric = $verse->[$pn];
        # print Dumper($lyric) . "\n";

        my $n = $rOffset;
        
        foreach my $syl (@{$lyric})
        {
          printf OFILE "%s", $syl;
          printf OFILE "-", if $ties{$n};
          print OFILE " " if ($n < $#{$rf} && !($syl =~ m~\-$~));
          $n++;
          while ($rf->[$n+$rOffset] < 0) {
            print OFILE "- ";
            ++$n;
          }
        }
        print OFILE "\n";
        ++$verseNo;
      }
    }
    # PRODUCE MIDI TRACK INFO for current $vn, $pn HERE...
    # @mEventLists = ([],[],[],[]);  # midi event lists for each voice
    # @mTimes = (0,0,0,0);           # midi clocks for each voice
    if ($li >= 0)
    {
      my $verses = $lyrics->[$li]->{verses};
     #  foreach my $verse (@{$verses})
     #  {
     my $verse = $verses->[0];
        my $lyric = $verse->[$pn];
        my $n = 0;  # note number
        $lastPitchM = 0;
        foreach my $syl (@{$lyric})
        {
          # determine time delta since end of last note, pitch, duration of pitch...
          # output lyric syllable, note on, velocity, note off...
          my $outsyl = $syl;
          $outsyl =~ s/[\-,\.]$//;
          my $timedelta = 0;
          if ($rDuration > 0) # incorporate leading rest
          {
            print "RD: $rDuration\n";
            $timedelta = $rDuration * 120;
            $rDuration = 0;
          }
          my ($pitchNo, $duration, $velocity) = TableToMIDI($vn,$mi,$pf->[$n],$rf->[$n+$rOffset]);
          push @{$mEventLists[$vn]}, ['lyric', $timedelta, $outsyl . ' '];
          
          push @{$mEventLists[$vn]}, ['note_on', 0, 0, $pitchNo, $velocity];
          push @{$mEventLists[$vn]}, ['note_on', $duration, 0, $pitchNo, 0];
          ++$n;
          while ($rf->[$n+$rOffset] < 0) 
          {
            my ($pitchNo, $duration, $velocity) = TableToMIDI($vn,$mi,$pf->[$n],abs($rf->[$n+$rOffset]));
            push @{$mEventLists[$vn]}, ['note_on', 0, 0, $pitchNo, $velocity];
            push @{$mEventLists[$vn]}, ['note_on', $duration, 0, $pitchNo, 0];
            ++$n;
          }
          # !! handle multiple notes per syllable here, incrementing $n
     #   }
      }
    }   
  }
}

close OFILE;
$psabcfile = $ofile;
$midabcfile = $ofile;
$psfile = $ofile;
$midfile = $ofile;

$psabcfile =~ s/\.abp/-ps.abc/;
$midabcfile =~ s/\.abp/-midi.abc/;
$psfile =~ s/\.abp/.ps/;
$midfile =~ s/\.abp/.mid/;


print `abcpp -ABCMIDI $dir$ofile $dir$midabcfile`;
print `abcpp $dir$ofile $dir$psabcfile`;
print `abcm2ps $dir$psabcfile -O $dir$psfile`;
print `abc2midi $dir$midabcfile -o $dir$midfile`;
# print `rm $dir$psabcfile`;
# print `rm $dir$midabcfile`;

# produce vocal midi files here...
if ($voce)
{
  foreach my $vn (0..3) {
    $vmidfile = $ofile;
    $vmidfile =~ s/\.abp/_$vn.mid/;

    my $op = MIDI::Opus->new({
      'format' => 1,
      'ticks'  => 120,  # ticks per quarternote
      'tracks' => [   # 2 tracks...

        # Track #0 ...
        MIDI::Track->new({
          'type' => 'MTrk',
          'events' => [  # 3 events.
            ['time_signature', 0, 4, 2, 24, 8],
            ['key_signature', 0, 0, 0],
            ['set_tempo', 0, int(1000000*60/$tempo)],  # microseconds per quarter note
          ]
        }),

        # Track #1 ...
        MIDI::Track->new({
          'type' => 'MTrk',
          'events' => $mEventLists[$vn]
          }),

        ]
      });
    $op->write_to_file("$dir$vmidfile");  
  }
}

exit;

sub TableToMIDI()
{
  my ($vn, $mi, $pn, $rn) = @_;  # voice number (0-3), mode-index (0-7), pitch number (1-8)
  my $pl = $modes->[$mi]->{pitches}->[$pn-1];
  my ($pitch,$acci) = $pl =~ m~([a-g])([\+\-])?~;

  # convert from pitch to number
  my $n = $noteToPitch->{$pitch};
  # apply accidental
  if ($acci eq '-') # || ($forceFlatB && (lc($pitch) eq 'b'))) 
  {
    $n--;
  }
  elsif ($acci eq '+') {
    $n++;
  }

  # coerce into range
  my $tonic = substr $modes->[$mi]->{pitches}->[0],0,1;
  my $lo = $registers->{$tonic}->[$vn]->{lo};
  my $hi = $registers->{$tonic}->[$vn]->{hi};
  #print "$vn $mi $pn tonic=$tonic $lo - $hi\n";
  #exit;
  # !! need to take melodic motion into account here as well!!
  while ($n < $lo) {
    $n += 12;
  }
  while ($n > $hi) {
    $n -= 12;
  }
  if ($pn == 1 && $n-12 >= $lo)
  {
    $n -= 12;
  }
  if ($pn == 8 && $n+12 <= $hi)
  {
    $n += 12;
  }

  # preserve stepwise motion....
  if ($lastPitchM > 0 && (defined $lastPitchM) &&
      abs(($lastPitchM % 12) - ($n % 12)) <= $ && 
      abs($lastPitchM - $n) > $vleading)
  {
    print "V: $vn Correcting ($lastPitchN $n) ...";
    my $n2 = $n + ($lastPitchM > $n? 12 : -12);
    # only allow if not too far outside natural range of voice
    if ($n2 > $lo-2 && $n2 < $hi+2) {
      $n = $n2;
    }
    print "$n\n"; 
  }
  $lastPitchM = $n;
  return ($n+12, $rn*120, 100);
}


sub TableToPitch()
{
  my ($vn, $mi, $pn) = @_;  # voice number (0-3), mode-index (0-7), pitch number (1-8)
  my $pl = $modes->[$mi]->{pitches}->[$pn-1];

  my ($pitch,$acci) = $pl =~ m~([a-g])([\+\-])?~;

  # convert from pitch to number
  my $n = $noteToPitch->{$pitch};
  
  # apply accidental
  if ($acci eq '-') # || ($forceFlatB && (lc($pitch) eq 'b'))) 
  {
    $n--;
  }
  elsif ($acci eq '+') {
    $n++;
  }

  # coerce into range
  my $tonic = substr $modes->[$mi]->{pitches}->[0],0,1;
  my $lo = $registers->{$tonic}->[$vn]->{lo};
  my $hi = $registers->{$tonic}->[$vn]->{hi};
  #print "$vn $mi $pn tonic=$tonic $lo - $hi\n";
  #exit;
  # !! need to take melodic motion into account here as well!!
  while ($n < $lo) {
    $n += 12;
  }
  while ($n > $hi) {
    $n -= 12;
  }
  if ($pn == 1 && $n-12 >= $lo)
  {
    $n -= 12;
  }
  if ($pn == 8 && $n+12 <= $hi)
  {
    $n += 12;
  }

  # preserve stepwise motion....
  if ($lastPitchN > 0 && (defined $lastPitchN) &&
      abs(($lastPitchN % 12) - ($n % 12)) <= $ && 
      abs($lastPitchN - $n) > $vleading)
  {
    print "V: $vn Correcting ($lastPitchN $n) ...";
    my $n2 = $n + ($lastPitchN > $n? 12 : -12);
    # only allow if not too far outside natural range of voice
    if ($n2 > $lo-2 && $n2 < $hi+2) {
      $n = $n2;
    }
    print "$n\n"; 
  }
  
  
  $lastPitchN = $n;


  # convert from number to abc designation, keeping key signature into account

  $pitch = $modes->[$mi]->{spelling}->[$n % 12];
  
  # hide accidentals which are already in key signuture
  if (substr($pitch,0,1) eq '_' && $myKeySig->{substr($pitch, 1)} ==  -1)
  {
    # print "FIXING B $pitch\n";
    $pitch = substr($pitch, 1);
  }
  elsif (substr($pitch,0,1) eq '^' && $myKeySig->{substr($pitch, 1)} ==  1)
  {
    $pitch = substr($pitch, 1);
  }
  # notate naturals
  elsif (substr($pitch,0,1) ne '_' && substr($pitch,0,1) ne '^' &&
         defined $myKeySig->{$pitch})
  {
    $pitch = '=' . $pitch;
  }
 
  # coerce into right register
  if ($n < 72) {
    $pitch = uc($pitch);
  }
  if ($n > 84) {
    $pitch .= "'";
  }
  if ($n < 60) {
    $pitch .= ",";
  }
  if ($n < 48) {
    $pitch .= ",";
  }
  if ($n < 36) {
    $pitch .= ",";
  }
  return $pitch;
}

# this will allow us to do other meters not based on quarter note...
sub TableToNotelength()
{
  my ($ri) = @_;
  return $ri if (int($ri) == $ri);
  # print "R $ri\n";
  return '/2' if $ri == .5;
  return '3/2' if $ri == 1.5;
  print "Unexpected Note length: $ri\n";
  exit;
}
