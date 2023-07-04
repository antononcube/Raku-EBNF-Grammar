use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;
use Test;

plan *;

##===========================================================
## 1-2
##===========================================================
my $ebnfCode1 = "
<top> = 'a' , 'b' , 'c' ;
";

## 1
isa-ok ebnf-grammar-graph($ebnfCode1), Str;

## 2
is so ebnf-grammar-graph($ebnfCode1) ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 3
##===========================================================
my $ebnfCode3 = "
<top> = 'a' <& 'b' <& 'c' ;
";

is so ebnf-grammar-graph($ebnfCode3) ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 4
##===========================================================
my $ebnfCode4 = "
<top> = 'a' &> 'b' &> 'c' ;
";

is so ebnf-grammar-graph($ebnfCode4) ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 5
##===========================================================
my $ebnfCode5 = "
top -> '4' | b
b -> 'b' | 'B'
";

is so ebnf-grammar-graph($ebnfCode5, style => 'Simple') ~~ / ^ graph .* '-->' /, True;

##===========================================================
## 6
##===========================================================

is so ebnf-grammar-graph($ebnfCode5, style => 'Simple', lang => 'WL') ~~ / ^ 'Graph[' .* 'DirectedEdge' /, True;


done-testing;
