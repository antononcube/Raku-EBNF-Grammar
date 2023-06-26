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
    token assign-symbol { '=' || '::=' || ':=' || ':' || '->' }
    token seq-sep { ',' | \h* }
    regex terminal { '"' <-['"]>+ '"' || '\'' <-['"]>+ '\'' }
    regex non-terminal { '<' <identifier> '>' || <identifier> }
    regex TOP { <ebnf> }
};

#-----------------------------------------------------------
grammar EBNF::Grammar::Inverted is export
                               does EBNF::Grammar::Standardish {

    token terminator { ";" | "." | \v* }
    token assign-symbol { '=' || '::=' || ':=' || ':' || '->' }
    token seq-sep { ',' | \h* }
    regex terminal { '"' <-['"]>+ '"' || '\'' <-['"]>+ '\'' || \w+ }
    regex non-terminal { '<' <identifier> '>' }
    regex TOP { <ebnf> }
};

#-----------------------------------------------------------
our sub ebnf-subparse(Str:D $command, Str:D :$rule = 'TOP', Bool :$relaxed) is export {
    return do if $relaxed {
        EBNF::Grammar::Relaxed.subparse($command, :$rule);
    } else {
        EBNF::Grammar.subparse($command, :$rule);
    }
}

#-----------------------------------------------------------
our sub ebnf-parse(Str:D $command, Str:D :$rule = 'TOP', Bool :$relaxed) is export {
    return do if $relaxed {
        EBNF::Grammar::Relaxed.parse($command, :$rule);
    } else {
        EBNF::Grammar.parse($command, :$rule);
    }
}

#-----------------------------------------------------------
our sub ebnf-interpret(Str:D $command,
                       Str:D:$rule = 'TOP',
                       :$actions is copy = Whatever,
                       :$name is copy = Whatever,
                       :$style = 'Standard',
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
    my $gr = do given $style {
        when $_ ~~ Str && $_.lc ∈ <relaxed simpler> {
            EBNF::Grammar::Relaxed.parse($command, :$rule, :$actions).made;
        }

        when $_ ~~ Str && $_.lc ∈ <inverted> {
            EBNF::Grammar::Inverted.parse($command, :$rule, :$actions).made;
        }

        when $_ ~~ Str && $_.lc ∈ <default standard> {
            EBNF::Grammar.parse($command, :$rule, :$actions).made;
        }

        default {
            die "Do not know how to process the argument style. Expected values are <Inverted Relaxed Standard> or Whatever";
        }
    }

    # Evaluate if specified
    if $eval {
        use MONKEY-SEE-NO-EVAL;
        return EVAL($gr);
    }

    # Result
    return $gr;
}
