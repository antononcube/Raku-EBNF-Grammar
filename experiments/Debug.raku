#!/usr/bin/env raku
use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;
use EBNF::Grammar::Standardish;

my $ebnf0 = q:to/END/;
<top> = 'a' | 'b' ;
END

my $ebnf1 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , 'A'* ;
<b> = 'b' | 'B' ;
END

my $ebnf2 = q:to/END/;
<top> -> <a> | <b>
a -> 'a' 'A'*
b -> 'b' | 'B'
END

my $ebnf10 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> ::= <digit> , { <digit> } ;
<top> = <number> ;
END

say ebnf-parse($ebnf1);

say '=' x 120;
say 'WHAT : ', ebnf-interpret($ebnf10).WHAT;
say ebnf-interpret($ebnf10);

say '=' x 120;

say "Relaxed :\n", ebnf-interpret($ebnf2):relaxed;
