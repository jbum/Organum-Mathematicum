Organum.pl - Jim Bumgardner

organum.pl is a script which recreates the music algorithm described in Athanasius Kircher's book
'Musurgia Universalis' (1650), and from "Organum Mathematicum" by Kaspar Schott.

For some background information, see Jim's paper:

http://krazydad.com/pubs/kircher_paper.pdf

organum.pl produces a file in the ABC music format, and then uses the ABC utilities to produce postscript
and MIDI renditions of the score.  You will need to compile/install some ABC-related utiliies
from http://abc.sourceforge.net/

You will need the following utilities:

abcpp    (ABC Plus preprocessor)
abcm2ps  (ABC to Postscript)
abc2midi (ABC to Midi)

organum.pl        The original script.
organumM.pl       A version which is intended for producing MIDI.
organumNoVoce.pl  This version does not produce vocal midi parts.

tariffa.ph        Transcibed data from Kircher and Schott's books.
kirchenmodes.ph   Modes (scales) from the books.
lyrics.ph         Latin hymn lyrics that work well with this data.

SAMPLE INVOCATIONS

# use a specific set of tables
organum.pl -li 6 -csn 6 -mi 6 -pi "5656" -tempo 180 -4part -vl 2 -o VeniCreator

# use a random set of tables
./organum.pl -li 5 -csn 4 -mi 6 -rnd -tempo 180 -4part -vl 2 -o VeniCreator
./organum.pl -li 6 -csn 6 -mi 6 -rnd -tempo 180 -4part -vl 2 -o VeniCreator

# ghostscript to jpeg conversion
gs -r300 -sDEVICE=jpeg -sOutputFile=VeniCreator_%d.jpg VeniCreatorSample.ps -c quit

