use v6.d;

use lib '.';
use lib './lib';

use EBNF::Grammar;
use Test;


plan *;

##===========================================================
## 1 - 7
##===========================================================
my $ebnfCode1 = "
<top> = 'a' | 'b' ;
";

## 1
ok ebnf-parse($ebnfCode1), 'Parsing works';


## 2
isa-ok ebnf-interpret($ebnfCode1, actions => 'Raku::FunctionalParsers'),
        Str,
        'Interpretation to FunctionalParsers produces a String';

## 3
isa-ok ebnf-interpret($ebnfCode1, actions => 'Raku::Grammar'),
        Str,
        'Interpretation to Grammar produces a String';

## 4
isa-ok ebnf-interpret($ebnfCode1, actions => 'Raku::AST'),
        Pair,
        'Interpretation to AST produces a Pair';

## 5
is ebnf-interpret($ebnfCode1, actions => 'Raku::AST').key,
        "EBNF",
        'Key of the result is "EBNF"';

## 6
is-deeply
        ebnf-interpret($ebnfCode1, actions => 'Raku::AST').value>>.key,
        ("EBNFRule",),
        'Value of the result is list of pairs with keys "EBNFRule"';

## 7
is-deeply
        ebnf-interpret($ebnfCode1, actions => 'Raku::AST').value.Hash,
        {:EBNFRule("<top>" => :EBNFAlternatives((:EBNFTerminal("\"a\""), :EBNFTerminal("\"b\""))))},
        'Expected pairs';

## 8
is-deeply
        ebnf-interpret($ebnfCode1, actions => 'Raku::AST'),
        ebnf-interpret($ebnfCode1, actions => 'Raku::AST'),
        'Same results for string and tokens';

##===========================================================
## 9 - 12
##===========================================================
my $ebnfCode9 = q:to/END/;
<b> = 'b' , [ '1' | '2' ] ;
END

## 9
ok ebnf-parse($ebnfCode9), 'Parsing ok (b opt)';

## 10
isa-ok ebnf-interpret($ebnfCode9, actions => 'Raku::AST'), Pair, 'Interpretation produces a pair (b opt)';

## 11
is-deeply
        ebnf-interpret($ebnfCode9, actions => 'Raku::AST').value.Hash,
        {:EBNFRule("<b>" => :EBNFSequence((:EBNFTerminal("\"b\""), :EBNFOption(:EBNFAlternatives((:EBNFTerminal("\"1\""), :EBNFTerminal("\"2\"")))))))},
        'Expected pairs (b opt)';

## 12
is-deeply
        ebnf-interpret($ebnfCode9, actions => 'Raku::AST'),
        ebnf-interpret($ebnfCode9, actions => 'Raku::AST'),
        'Same results for string and tokens (b opt)';

##===========================================================
## 13 - 17
##===========================================================
my $ebnfCode13 = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<number> = <digit> , { <digit> } ;
<top> = <number> ;
END

## 13
isa-ok ebnf-interpret($ebnfCode13, actions => 'Raku::AST'),
        Pair,
        'Interpretation produces a pair (number)';

## 14
is ebnf-interpret($ebnfCode13, actions => 'Raku::AST').value ~~ List,
        True,
        'Interpretation produces a pair with value that is a list (number)';

## 15
is-deeply
        ebnf-interpret($ebnfCode13, actions => 'Raku::AST').value>>.key,
        <EBNFRule EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (number)';

## 16
is-deeply
        ebnf-interpret($ebnfCode13, actions => 'Raku::AST').value>>.value>>.key,
        ("<digit>", "<number>", "<top>"),
        'Expected rule names (number)';

## 17
is-deeply
        ebnf-interpret($ebnfCode13, actions => 'Raku::AST'),
        ebnf-interpret($ebnfCode13, actions => 'Raku::AST'),
        'Same results for string and tokens (number)';

##===========================================================
## 18 - 23
##===========================================================
my $ebnfCode18 = q:to/END/;
<top> = 'a' <& 'b' <& 'c' <& 'd' | <right> ;
<right> = 'e' &> 'f' &> 'g' &> 'h' ;
END

## 18
isa-ok ebnf-interpret($ebnfCode18, actions => 'Raku::AST'),
        Pair,
        'Interpretation produces a Pair (<& &>)';

## 19
isa-ok ebnf-interpret($ebnfCode18, actions => 'Raku::AST').value,
        List,
        'Interpretation produces a Pair with a List value (<& &>)';

## 20
is-deeply
        ebnf-interpret($ebnfCode18, actions => 'Raku::AST').value>>.key,
        <EBNFRule EBNFRule>,
        'Value of the result is list of pairs with keys "EBNFRule" (<& &>)';

## 21
is-deeply
        ebnf-interpret($ebnfCode18, actions => 'Raku::AST').value>>.value>>.key,
        ("<top>", "<right>"),
        'Expected rule names (<& &>)';

## 22
is-deeply
        [ebnf-interpret($ebnfCode18, actions => 'Raku::AST').value.head,],
        $[:EBNFRule("<top>" => :EBNFAlternatives((:EBNFSequencePickLeft((:EBNFTerminal("\"a\""), :EBNFSequencePickLeft((:EBNFTerminal("\"b\""), :EBNFSequencePickLeft((:EBNFTerminal("\"c\""), :EBNFTerminal("\"d\""))))))), :EBNFNonTerminal("<right>"))))],
        'Expected rule structure, <top> (<& &>)';

## 23
is-deeply
        [ebnf-interpret($ebnfCode18, actions => 'Raku::AST').value[1],],
        $[:EBNFRule("<right>" => :EBNFSequencePickRight((:EBNFTerminal("\"e\""), :EBNFSequencePickRight((:EBNFTerminal("\"f\""), :EBNFSequencePickRight((:EBNFTerminal("\"g\""), :EBNFTerminal("\"h\""))))))))],
        'Expected rule structure, <right> (<& &>)';

##===========================================================
## 24
##===========================================================
my $ebnfCode24 = q:to/END/;
<top> = 'a' , 'b' , 'c' , 'd';
END

## 24
is-deeply
        [ebnf-interpret($ebnfCode24, actions => 'Raku::AST').value.head,],
        $[:EBNFRule("<top>" => :EBNFSequence((:EBNFTerminal("\"a\""), :EBNFTerminal("\"b\""), :EBNFTerminal("\"c\""), :EBNFTerminal("\"d\""))))],
        'Expected rule structure, <top> (,)';


##===========================================================
## 25
##===========================================================
my $ebnfCode25 = q:to/END/;
<top> = ( 'a' | 'b' ) , ( 'c' | 'd' );
END

my $res25 = q:to/END/;
grammar FP {
	rule top { ['a' | 'b'] ['c' | 'd'] }
}
END

## 25
is
        ebnf-interpret($ebnfCode25, actions => 'Raku::Grammar', name => 'FP', rule-type => 'rule').trim.subst(/\s+/, ' '),
        $res25.trim.subst(/\s+/, ' '),
        "Expected grammar for ( 'a' | 'b' ) , ( 'c' | 'd' )";

##===========================================================
## 26
##===========================================================
my $ebnfCode26 = q:to/END/;
<top> = ( 'a' | 'b' ) &> <right>;
<right> = 'M' , ( 'c' | 'd' );
END

my $res26 = q:to/END/;
grammar FP {
	rule top { ['a' | 'b'] <right> }
	rule right { 'M' ['c' | 'd'] }
}
END

## 26
is
        ebnf-interpret($ebnfCode26, actions => 'Raku::Grammar', name => 'FP', rule-type => 'rule').trim.subst(/\s+/, ' '),
        $res26.trim.subst(/\s+/, ' '),
        "Expected grammar for ( 'a' | 'b' ) , ( 'c' | 'd' )";


done-testing;
