# mode and voice range info
#
# Data from Illustration of Arca Musurgia (Kircher, 1650) and Organum Mathematicum (Kaspar Schott)
#
# Jim Bumgardner, from photos provided by Hans-Joachim Vollrath

# choice of B,Bb under advisement from Musicologist Jeffrey Dean

$modes = [
{name=>"Dorian (Durus)", 		
	pitches=>['d','e','f','g','a','b-','c+','d'], 	# with notated flat b
	keysig => {b=>-1,label=>'Dm'},
	spelling => ['c', '^c','d','_e','e','f','_g','g','_a','a','_b','b'],
	},
{name=>"Hypodorian (Mollis)", 		
	pitches=>['g','a','b-','c','d','e-','f+','g'],	
	keysig => {b=>-1,e=>-1,label=>'Gm'},
	spelling => ['c', '_d','d','_e','e','f','^f','g','_a','a','_b','b'],
	},
{name=>"Phrygian (Mollis)", 		
	pitches=>['a','b-','c','d','e','f','g+','a'],	
	keysig => {label=>'Am'},
	spelling => ['c', '^c','d','^d','e','f','^f','g','^g','a','_b','b']
	},
{name=>"Hypophrygian (Durus)", 		
	pitches=>['a','b','c+','d','e','f','g','a'],    
	keysig => {label=>'Am'},
	spelling => ['c', '^c','d','^d','e','f','^f','g','^g','a','_b','b']
	},
{name=>"Lydian (Mollis)",		
	pitches=>['b-','c','d','e','f','g','a','b-'], # Bb with sharp 4 (lydian)
	keysig => {b=>-1,label=>'F'},
	spelling => ['c', '_d','d','_e','e','f','_g','g','_a','a','_b','b']
	},
{name=>"Hypolydian (Mollis)",		
	pitches=>['f','g','a','b-','c','d','e','f'],  # f major   
	keysig => {b=>-1,label=>'F'},
	spelling => ['c', '_d','d','_e','e','f','_g','g','_a','a','_b','b'],
	},
{name=>"Mixolydian (Durus)",		
	pitches=>['g','a','b','c','d','e','f+','g'],  # g major  
	keysig => {b=>-1,e=>-1,label=>'Gm'},
	spelling => ['c', '_d','d','_e','e','f','^f','g','_a','a','_b','b'],
	},
{name=>"Hypomixolydian (Durus)",
	pitches=>['g','a','b','c','d','e-','f+','g'], # g major with flat 6
	keysig => {b=>-1,e=>-1,label=>'Gm'},
	spelling => ['c', '_d','d','_e','e','f','^f','g','_a','a','_b','b'],
	},
# add Glareanus modes from Arca here...
];

$noteToPitch = {a=>57, b=>59, c=>60, d=>62, e=>64, f=>65, g=>67}; # converts lowercase note letter to pitch number 

# this is based on mod 12

# Note that middle C maps to 60
# data from class 5 cards
$registers = {
'a' => [{lo=>64,hi=>76},  # E to E
        {lo=>57,hi=>69},  # A to A
        {lo=>52,hi=>64},  # E to E
        {lo=>45,hi=>57}], # A to A

'b' => [{lo=>65,hi=>77},  # F to F
        {lo=>53,hi=>65},  # F to F
        {lo=>53,hi=>65},  # F to F
        {lo=>46,hi=>59}], # Bb to B(nat)

'c' => [{lo=>60,hi=>76},  # C to E  # note wide range if coming from 8 move into upper register
        {lo=>55,hi=>67},  # G to G
        {lo=>55,hi=>67},  # G to G
        {lo=>48,hi=>60}], # C to C

'd' => [{lo=>62,hi=>74},  # D to D
        {lo=>57,hi=>69},  # A to A
        {lo=>50,hi=>62},  # D to D
        {lo=>48,hi=>60}], # C to C

'e' => [{lo=>63,hi=>76},  # Eb to E
        {lo=>55,hi=>67},  # G to G
        {lo=>51,hi=>64},  # Eb to E(nat)
        {lo=>39,hi=>52}], # Eb to E(nat)

'f' => [{lo=>65,hi=>77},  # F to F
        {lo=>53,hi=>69},  # F to A  # wide range
        {lo=>48,hi=>65},  # C to F  # wide range
        {lo=>41,hi=>55}], # F to G  # wide range (G might be a blot)

'g' => [{lo=>62,hi=>74},  # D to D
        {lo=>55,hi=>67},  # G to G
        {lo=>50,hi=>62},  # D to D(nat)
        {lo=>43,hi=>55}], # G to G(nat)
};

$voices = [
{name=>"Cantus",clef=>'treble',stave=>'C'},
{name=>"Altus",clef=>'treble',stave=>'A'},
{name=>"Tenor",clef=>'bass',stave=>'T'},
{name=>"Bassus",clef=>'bass',stave=>'B'},
];

return 1;

