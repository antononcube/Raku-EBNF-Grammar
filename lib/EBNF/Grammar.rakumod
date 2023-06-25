use v6.d;

use EBNF::Grammar::Standardish;
use EBNF::Actions::Raku::Grammar;

#-----------------------------------------------------------
grammar EBNF::Grammar
        does EBNF::Grammar::Standardish {
    regex TOP { <ebnf> }
}

#-----------------------------------------------------------
grammar EBNF::Grammar::Relaxed is export
        does EBNF::Grammar::Standardish {

    token terminator { ";" | "." | \v* }
    token assign-symbol { '=' | ':=' | '::=' | '->' }
    token seq-sep { ',' | \h* }
    regex non-terminal { '<' <identifier> '>' || <identifier> }
    regex TOP { <ebnf> }
};

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
                       Bool :$relaxed = False,
                       Bool :$eval = False) is export {


    if $name.isa(Whatever) {
        $name = 'EBNF-' ~ DateTime.now.Instant.Num.subst('.', '-');
    }

    die 'The argument $name is expected to be a string or Whatever'
    unless $name ~~ Str;

    if $actions.isa(Whatever) {
        $actions = EBNF::Actions::Raku::Grammar.new(:$name);
    }

    my $gr = do if $relaxed {
        EBNF::Grammar::Relaxed.parse($command, :$rule, :$actions).made;
    } else {
        EBNF::Grammar.parse($command, :$rule, :$actions).made;
    }

    if $eval {
        use MONKEY-SEE-NO-EVAL;
        return EVAL($gr);
    }

    return $gr;
}
