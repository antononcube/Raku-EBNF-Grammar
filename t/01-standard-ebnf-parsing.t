use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;
use Test;


plan *;

##===========================================================
## 1 - 4
##===========================================================
my $ebnfCode1 = "
<top> = 'a' | 'b' ;
";

## 1
ok ebnf-parse($ebnfCode1), 'parsing 1';

## 2
ok ebnf-subparse($ebnfCode1, style => 'Standard'), 'parsing 1';

## 3
isa-ok ebnf-interpret($ebnfCode1, :!eval), Str, 'interpretation with :!eval is a string';

## 4
isa-ok ebnf-interpret($ebnfCode1, :eval), Grammar, 'interpretation with :eval is a grammar';

## 5
my grammar Test4 {
    regex TOP { 'a' | 'b' }
};

my $query4 = 'a';
my $pres4 = Test4.parse($query4);
my $gr4 = ebnf-interpret($ebnfCode1, name => 'MyTest3'):eval;

is-deeply $gr4.parse($query4, rule=>'top'), $pres4, 'equivalence';

##===========================================================
## 6 - 9
##===========================================================
my $ebnfCode5 = q:to/END/;
<b> = 'b' , [ '1' | '2' ] ;
END

## 6
ok ebnf-parse($ebnfCode5), 'parsing <b>';

## 7
isa-ok ebnf-interpret($ebnfCode5, :!eval), Str, 'interpretation with :!eval is a string, <b>';

## 8
isa-ok ebnf-interpret($ebnfCode5, name => 'MyEBNFTest7', :eval), Grammar, 'interpretation with :eval is a grammar, <b>';

## 9
my grammar Test8 {
    regex b { 'b' [ '1' | '2' ]? }
};

my $query8 = 'b1';
my $pres8 = Test8.parse($query8, rule => 'b');
my $gr8 = ebnf-interpret($ebnfCode5, name => 'MyTest8'):eval;

is-deeply $gr8.parse($query8, rule=>'b'), $pres8, 'equivalence, <b>';

##===========================================================
## 10 - 13
##===========================================================
my $ebnfCode9 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } ;
<top> = <number> ;
END

## 10
ok ebnf-parse($ebnfCode9), 'parsing <b>';

## 11
isa-ok ebnf-interpret($ebnfCode9, :!eval), Str, 'interpretation with :!eval is a string, <digit>';

## 12
isa-ok ebnf-interpret($ebnfCode9, name => 'MyEBNFTest11', :eval), Grammar, 'interpretation with :eval is a grammar, <digit>';

## 13
my grammar Test12 {
    regex digit { '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' }
    regex number { <digit>+ }
    regex TOP { <number> }
};

my $query12 = '123';
my $pres12 = Test12.parse($query12, rule => 'TOP');
my $gr12 = ebnf-interpret($ebnfCode9, name => 'MyTest12'):eval;

is-deeply $gr12.parse($query12, rule=>'top'), $pres12, 'equivalence, <digit>';


##===========================================================
## 18 - 23
##===========================================================
my $ebnfCode18 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END


done-testing;
