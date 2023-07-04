use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;
use Test;

plan *;

##===========================================================
## 1
##===========================================================
my $ebnfCode1 = "
<top> = 'a' , 'b' , 'c' ;
";

## 1
is-deeply ebnf-interpret($ebnfCode1, actions => 'Raku::AST').Hash,
        {:EBNF((:EBNFRule("<top>" => :EBNFSequence((:EBNFTerminal("\"a\""), :EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))),))},
        'Comma separated';

##===========================================================
## 2
##===========================================================
my $ebnfCode2 = "
<top> = 'a' <& 'b' <& 'c' ;
";

## 2
is-deeply ebnf-interpret($ebnfCode2, actions => 'Raku::AST').Hash,
        ${:EBNF($(:EBNFRule("<top>" => :EBNFSequencePickLeft((:EBNFTerminal("\"a\""), :EBNFSequencePickLeft((:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))))),))},
        'Pick left separated';

# In FunctionalParsers this is produced:
# {:EBNF((:EBNFRule("<top>" => :EBNFSequencePickLeft(($(:EBNFTerminal("\"a\""), :EBNFTerminal("\"b\"")), :EBNFTerminal("\"c\"")))),))},

##===========================================================
## 3
##===========================================================
my $ebnfCode3 = "
<top> = 'a' &> 'b' &> 'c' ;
";

## 3
is-deeply ebnf-interpret($ebnfCode3, actions => 'Raku::AST').Hash,
        ${:EBNF($(:EBNFRule("<top>" => :EBNFSequencePickRight((:EBNFTerminal("\"a\""), :EBNFSequencePickRight((:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))))),))},
        'Pick right separated';

# In FunctionalParsers this is produced:
# {:EBNF((:EBNFRule("<top>" => :EBNFSequencePickRight((:EBNFTerminal("\"a\""), $(:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\""))))),))},

##===========================================================
## 4
##===========================================================
my $ebnfCode4 = "
<top> = 'a' &> 'b' , 'c' ;
";

## 4
is-deeply ebnf-interpret($ebnfCode4, actions => 'Raku::AST').Hash,
        ${:EBNF($(:EBNFRule("<top>" => :EBNFSequencePickRight((:EBNFTerminal("\"a\""), :EBNFSequence($(:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))))),))},
        'Pick right and comma separated';

# In FunctionalParsers this is produced:
# {:EBNF((:EBNFRule("<top>" => :EBNFSequencePickRight((:EBNFTerminal("\"a\""), :EBNFSequence((:EBNFTerminal("\"b\""), :EBNFTerminal("\"c\"")))))),))},

##===========================================================
## 5
##===========================================================
my $ebnfCode5 = "
<top> = <a> &> <b> , <c> ;
";

## 5
is-deeply ebnf-interpret($ebnfCode5, actions => 'Raku::Grammar', name => 'FP', rule-type => 'rule').subst(/ \s+ /, ' ', :g).trim,
        'grammar FP { rule top { <.a> <b> <c> } }',
        'Pick right and comma separated, Grammar';


##===========================================================
## 6
##===========================================================
my $ebnfCode6 = "
<top> = <a> &> <b> , <c> <& <d> ;
";

## 6
is-deeply ebnf-interpret($ebnfCode6, actions => 'Raku::Grammar', name => 'FP').subst(/ \s+ /, ' ', :g).trim,
        'grammar FP { regex top { <.a> <b> <c> <.d> } }',
        'Pick right, comma separated, pick left, Grammar';


##===========================================================
## 7
##===========================================================

## 7
is-deeply ebnf-interpret($ebnfCode6, actions => 'Raku::FunctionalParsers').lines[1].subst(/ \s+ /, ' ', :g).trim,
        'method pTOP(@x) { sequence-pick-right({self.pA($_)}, sequence({self.pB($_)}, sequence-pick-left({self.pC($_)}, {self.pD($_)})))(@x) }',
        'Pick right, comma separated, pick left, FunctionalParsers';

##===========================================================
## 8
##===========================================================
my $res8 = q:to/END/;
class FP {
  method pTOP(@x) { sequence-pick-right({self.pA($_)}, sequence({self.pB($_)}, sequence-pick-left({self.pC($_)}, {self.pD($_)})))(@x) }
  has &.parser is rw = -> @x { self.pTOP(@x) };
}
END

## 8
is-deeply ebnf-interpret($ebnfCode6, actions => 'Raku::FunctionalParsers', name => 'FP').subst(/ \s+ /, ' ', :g).trim,
        $res8.subst(/ \s+ /, ' ', :g).trim,
        'Pick right, comma separated, pick left, FunctionalParsers';

##===========================================================
## 9
##===========================================================
my $ebnfCode9 = "
<top> = <a> &> <b> , <c> <& <d> <& <e> ;
";

## 9
is-deeply ebnf-interpret($ebnfCode9, actions => 'Raku::Grammar', name => 'FP').subst(/ \s+ /, ' ', :g).trim,
        'grammar FP { regex top { <.a> <b> <c> <.d> <.e> } }',
        'Pick right, comma separated, pick left, pick left, Grammar';


done-testing;
