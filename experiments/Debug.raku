#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;

my $ebnf0 = q:to/END/;
<top> = 'a' | 'b' ;
END

my $ebnf1 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , 'A' ;
<b> = 'b' | 'B' ;
END

my $ebnf2 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } <@ &{$_.flat.join} ;
<top> = <number> ;
END

say ebnf-parse($ebnf1);

say '=' x 120;
say ebnf-interpret($ebnf1);