use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;
use Test;


plan *;

##===========================================================
## 1 - 2
##===========================================================
my $ebnfCode1 = "
<sentence> : <subject> <verb> <object>
<subject> : I | we
<verb> : hate | love
<object> : R | WL | Julia
";

## 1
ok ebnf-parse($ebnfCode1):relaxed, 'parsing 1';

## 2
my $grCode2 = q:to/END/;
grammar MyEBNF {
    regex sentence { <subject> <verb> <object> }
 	regex subject { 'I' | 'we' }
 	regex verb { 'hate' | 'love' }
    regex object { 'R' | 'WL' | 'Julia' }
}
END

is
        ebnf-interpret($ebnfCode1, name => 'MyEBNF', style => 'inverted', :!eval).trim.subst(/\s/,''):g,
        $grCode2.trim.subst(/\s/,''):g,
        'expected generated code';

##===========================================================
## 3 - 4
##===========================================================
my $ebnfCode3 = "
sentence ::= subject VERB object
subject ::= 'I' | 'we'
VERB ::= 'hate' | 'love'
object ::= 'R' | 'WL' | 'Julia'
";

## 1
ok ebnf-parse($ebnfCode3):relaxed, 'parsing 1';

## 2
my $grCode4 = q:to/END/;
grammar MyEBNF {
    regex sentence { <subject> <VERB> <object> }
 	regex subject { 'I' | 'we' }
 	regex VERB { 'hate' | 'love' }
    regex object { 'R' | 'WL' | 'Julia' }
}
END

is
        ebnf-interpret($ebnfCode3, name => 'MyEBNF',  style => 'relaxed', :!eval).trim.subst(/\s/,''):g,
        $grCode4.trim.subst(/\s/,''):g,
        'expected generated code';

done-testing;
