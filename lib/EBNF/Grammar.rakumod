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
my $msgStyle = "Do not know how to process the argument style." ~
        "Expected values are <Inverted Relaxed Standard> or Whatever";

our sub ebnf-subparse(Str:D $command,
                   Str:D :$rule = 'TOP',
                   :$style = 'Standard') is export {
    # This code is repeated to large extend below,
    # but it seems too much effort to properly re-factor.
    # It would have been nice to use .^lookup e.g.
    #   EBNF::Grammar::Relaxed.^lookup($method)(EBNF::Grammar::Relaxed.new(orig => $command), :$rule);
    # But after trying for awhile to apply advice here https://stackoverflow.com/a/75128545
    # I did not get the "universal" code working.

    return do given $style {
        when $_ ~~ Str && $_.lc ∈ <relaxed simpler> {
            EBNF::Grammar::Relaxed.subparse($command, :$rule);
        }

        when $_ ~~ Str && $_.lc ∈ <inverted> {
            EBNF::Grammar::Inverted.subparse($command, :$rule);
        }

        when $_ ~~ Str && $_.lc ∈ <default standard> {
            EBNF::Grammar.parse($command, :$rule);
        }

        default {
            die $msgStyle;
        }
    }
}

#-----------------------------------------------------------
our sub ebnf-parse(Str:D $command,
                   Str:D :$rule = 'TOP',
                   :$style = 'Standard') is export {

    return do given $style {
        when $_ ~~ Str && $_.lc ∈ <relaxed simpler> {
            EBNF::Grammar::Relaxed.parse($command, :$rule);
        }

        when $_ ~~ Str && $_.lc ∈ <inverted> {
            EBNF::Grammar::Inverted.parse($command, :$rule);
        }

        when $_ ~~ Str && $_.lc ∈ <default standard> {
            EBNF::Grammar.parse($command, :$rule);
        }

        default {
            die $msgStyle;
        }
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
            die $msgStyle;
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
