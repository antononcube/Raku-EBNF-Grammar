use v6.d;

use EBNF::Grammar::Standardish;
use EBNF::Actions::Raku::Grammar;
use EBNF::Actions::Raku::FunctionalParsers;
use EBNF::Actions::WL::FunctionalParsers;

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


    # Process name
    if $name.isa(Whatever) {
        $name = 'EBNF_' ~ DateTime.now.Instant.Num.subst('.', '_');
    }

    die 'The argument $name is expected to be a string or Whatever'
    unless $name ~~ Str;

    # Process actions
    if $actions.isa(Whatever) { $actions = 'Raku::Grammar'; }

    $actions = do given $actions {
        when $_ ~~ Str && $_.lc ∈ <raku raku::grammar grammar> {
            EBNF::Actions::Raku::Grammar.new(:$name);
        }

        when $_ ~~ Str && $_.lc ∈ <raku::functionalparsers functionalparsers combinators> {
            EBNF::Actions::Raku::FunctionalParsers.new(:$name);
        }

        when $_ ~~ Str {
            ::("EBNF::Actions::{$actions}").new(:$name);
        }

        default {
            $actions
        }
    }

    # Parse / interpret
    my $gr = do if $relaxed {
        EBNF::Grammar::Relaxed.parse($command, :$rule, :$actions).made;
    } else {
        EBNF::Grammar.parse($command, :$rule, :$actions).made;
    }

    # Evaluate if specified
    if $eval {
        use MONKEY-SEE-NO-EVAL;
        return EVAL($gr);
    }

    # Result
    return $gr;
}
