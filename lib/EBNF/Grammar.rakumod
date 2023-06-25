use v6.d;

use EBNF::Grammarish;
use EBNF::Actions::Raku::Grammar;

grammar EBNF::Grammar
        does EBNF::Grammarish {
    regex TOP { <pGRAMMAR> }
}

#-----------------------------------------------------------
our sub ebnf-subparse(Str:D $command, Str:D :$rule = 'TOP') is export {
    EBNF::Grammar.subparse($command, :$rule);
}

our sub ebnf-parse(Str:D $command, Str:D :$rule = 'TOP') is export {
    EBNF::Grammar.parse($command, :$rule);
}

our sub ebnf-interpret(Str:D $command,
                       Str:D:$rule = 'TOP',
                       :$actions = EBNF::Actions::Raku::Grammar.new) is export {
    return EBNF::Grammar.parse($command, :$rule, :$actions).made;
}
