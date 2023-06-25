use v6.d;

use EBNF::Grammar::Standardish;
use EBNF::Actions::Raku::Grammar;

#-----------------------------------------------------------
grammar EBNF::Grammar
        does EBNF::Grammar::Standardish {
    regex TOP { <ebnf> }
}

#-----------------------------------------------------------
our sub ebnf-subparse(Str:D $command, Str:D :$rule = 'TOP') is export {
    EBNF::Grammar.subparse($command, :$rule);
}

#-----------------------------------------------------------
our sub ebnf-parse(Str:D $command, Str:D :$rule = 'TOP') is export {
    EBNF::Grammar.parse($command, :$rule);
}

#-----------------------------------------------------------
our sub ebnf-interpret(Str:D $command,
                       Str:D:$rule = 'TOP',
                       :$actions is copy = Whatever,
                       :$name is copy = Whatever,
                       Bool :$eval = False) is export {


    if $name.isa(Whatever) {
        $name = 'MyEBNFGrammar';
    }

    die 'The argument $name is expected to be a string or Whatever'
    unless $name ~~ Str;

    if $actions.isa(Whatever) {
        $actions = EBNF::Actions::Raku::Grammar.new(:$name);
    }

    my $gr = EBNF::Grammar.parse($command, :$rule, :$actions).made;

    if $eval {
        use MONKEY-SEE-NO-EVAL;
        return EVAL($gr);
    }

    return $gr;
}
