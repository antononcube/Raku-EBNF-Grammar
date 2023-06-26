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
ok ebnf-parse($ebnfCode1, style => 'Relaxed'), 'parsing 1';

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

## 3
ok ebnf-parse($ebnfCode3, style => 'Relaxed'), 'parsing 1';

## 4
my $grCode4 = q:to/END/;
grammar MyEBNF {
    regex sentence { <subject> <VERB> <object> }
 	regex subject { 'I' | 'we' }
 	regex VERB { 'hate' | 'love' }
    regex object { 'R' | 'WL' | 'Julia' }
}
END

is
        ebnf-interpret($ebnfCode3, name => 'MyEBNF', style => 'relaxed', :!eval).trim.subst(/\s/,''):g,
        $grCode4.trim.subst(/\s/,''):g,
        'expected generated code';

##===========================================================
## 5 - 6
##===========================================================
my $ebnfCode5 = '
SENTENCE = SUBJECT VERB OBJECT
SUBJECT = "I" | "we"
VERB = "hate" | "love"
OBJECT = "R" | "WL" | "Julia"
';

## 5
ok ebnf-parse($ebnfCode5, style => 'Relaxed'), 'parsing 1';

## 6
my $grCode6 = q:to/END/;
grammar MyEBNF {
    regex SENTENCE { <SUBJECT> <VERB> <OBJECT> }
 	regex SUBJECT { "I" | "we" }
 	regex VERB { "hate" | "love" }
    regex OBJECT { "R" | "WL" | "Julia" }
}
END

is
        ebnf-interpret($ebnfCode5, name => 'MyEBNF', style => 'relaxed', :!eval).trim.subst(/\s/,''):g,
        $grCode6.trim.subst(/\s/,''):g,
        'expected generated code';

done-testing;
