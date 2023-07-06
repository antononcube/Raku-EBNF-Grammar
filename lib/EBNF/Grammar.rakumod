use v6.d;

use EBNF::Grammar::Standardish;
use EBNF::Actions::EBNF::Standard;
use EBNF::Actions::MermaidJS::Graph;
use EBNF::Actions::Raku::AST;
use EBNF::Actions::Raku::Grammar;
use EBNF::Actions::Raku::FunctionalParsers;
use EBNF::Actions::WL::FunctionalParsers;
use FunctionalParsers::EBNF;

#-----------------------------------------------------------
grammar EBNF::Grammar
        does EBNF::Grammar::Standardish {
    regex TOP { <ebnf> }
}

#-----------------------------------------------------------
grammar EBNF::Grammar::Relaxed is export
                               does EBNF::Grammar::Standardish {

    token terminator { ";" | "."  | <WS> }
    regex assign-symbol { '=' || '::=' || ':=' || ':' || '->' || '→' }
    token seq-sep-comma { <.WS> ',' <.WS> | <WS> }
    regex terminal { '"' <-['"]>+ '"' || '\'' <-['"]>+ '\'' }
    regex non-terminal { '<' [ <identifier> | <identifier-phrase> ] '>' || <identifier> }
    regex TOP { <ebnf> }
};

#-----------------------------------------------------------
grammar EBNF::Grammar::Inverted is export
                                does EBNF::Grammar::Standardish {

    token terminator { ";" | "."  | <WS> }
    regex assign-symbol { '=' || '::=' || ':=' || ':' || '->' || '→' }
    token seq-sep-comma { <.WS> ',' <.WS> | <WS> }
    regex terminal { '"' <-['"]>+ '"' || '\'' <-['"]>+ '\'' || \w+ }
    regex non-terminal { '<' [ <identifier> | <identifier-phrase> ] '>' }
    regex TOP { <ebnf> }
};

#-----------------------------------------------------------
grammar EBNF::Grammar::Overall is export
                                is EBNF::Grammar
                                is EBNF::Grammar::Relaxed
                                is EBNF::Grammar::Inverted {


    regex TOP {
        || <EBNF::Grammar::ebnf>
        || <EBNF::Grammar::Inverted::ebnf>
        || <EBNF::Grammar::Relaxed::ebnf>
    }
};

#-----------------------------------------------------------
my $msgStyle = "Do not know how to process the argument style." ~
        "Expected values are <Inverted Relaxed Standard> or Whatever";

sub pick-parser(:$style!) {

    return do given $style {
        when $_.isa(Whatever)                               { EBNF::Grammar::Overall; }
        when $_ ~~ Str && $_.lc ∈ <overall whatever>        { EBNF::Grammar::Overall; }
        when $_ ~~ Str && $_.lc ∈ <relaxed simpler simple>  { EBNF::Grammar::Relaxed; }
        when $_ ~~ Str && $_.lc ∈ <inverted>                { EBNF::Grammar::Inverted; }
        when $_ ~~ Str && $_.lc ∈ <default standard>        { EBNF::Grammar; }

        default { die $msgStyle; }
    }
}

#-----------------------------------------------------------

our sub ebnf-subparse(Str:D $command,
                   Str:D :$rule = 'TOP',
                   :$style = 'Standard') is export {

    my $p = pick-parser(:$style);
    return $p.subparse($command, :$rule);
}

#-----------------------------------------------------------
our sub ebnf-parse(Str:D $command,
                   Str:D :$rule = 'TOP',
                   :$style = 'Standard') is export {

    my $p = pick-parser(:$style);
    return $p.parse($command, :$rule);
}

#-----------------------------------------------------------
our sub ebnf-interpret(Str:D $command,
                       Str:D:$rule = 'TOP',
                       :$actions is copy = Whatever,
                       :$name is copy = Whatever,
                       :$style = 'Standard',
                       Bool :$eval = False,
                       *%args
                       ) is export {


    # Process name
    if $name.isa(Whatever) {
        $name = 'EBNF_' ~ DateTime.now.Instant.Num.subst('.', '_');
    }

    die 'The argument $name is expected to be a string or Whatever'
    unless $name ~~ Str;

    # Process actions
    if $actions.isa(Whatever) { $actions = 'Raku::Grammar'; }

    $actions = do given $actions {
        when $_ ~~ Str && $_.lc ∈ <raku::ast ast> {
            EBNF::Actions::Raku::AST.new(:$name, |%args);
        }

        when $_ ~~ Str && $_.lc ∈ <raku raku::grammar grammar> {
            EBNF::Actions::Raku::Grammar.new(:$name, |%args);
        }

        when $_ ~~ Str && $_.lc ∈ <raku::functionalparsers functionalparsers combinators> {
            EBNF::Actions::Raku::FunctionalParsers.new(:$name, |%args);
        }

        when $_ ~~ Str && $_.lc ∈ <mermaid mermaid-js mermaid.js> {
            EBNF::Actions::MermaidJS::Graph.new(:$name, |%args);
        }

        when $_ ~~ Str {
            ::("EBNF::Actions::{$actions}").new(:$name, |%args);
        }

        default {
            $actions
        }
    }

    # Parse / interpret
    my $p = pick-parser(:$style);
    my $gr = $p.parse($command.chomp ~ "\n", :$rule, :$actions).made;

    # Evaluate if specified
    if $eval {
        use MONKEY-SEE-NO-EVAL;
        return EVAL($gr);
    }

    # Result
    return $gr;
}

#-----------------------------------------------------------
#| Make a graph for a given grammar.
proto ebnf-grammar-graph($g, |) is export {*}

multi sub ebnf-grammar-graph(Str $ebnf,
                             :$style is copy = 'Standard',
                             :actions(:$lang) = Whatever,
                             *%args) {

    my $res = ebnf-interpret($ebnf, :$style, actions => 'Raku::AST');

    die "Cannot parse the given grammar."
    unless $res ~~ Pair && *.key eq 'EBNF';

    return ebnf-grammar-graph($res, :$lang, |%args);
}

multi sub ebnf-grammar-graph(Pair $ebnfAST where *.key eq 'EBNF',
                             :actions(:$lang) is copy = Whatever,
                             *%args) {

    if $lang.isa(Whatever) { $lang = 'MermaidJS'; }

    die "The value of the argument $lang is expected to be MeramidJS, WL, or Whatever."
    unless $lang ~~ Str && $lang.lc ∈ <mermaid mermaid-js mermaidjs wl mathematica>;

    $lang = do given $lang.lc {
        when $_  ∈ <mermaid mermaid-js mermaidjs> { 'MermaidJS' }
        when $_  ∈ <wl mathematica> { 'WL' }
    }

    my $mname = "FunctionalParsers::EBNF::Actions::{$lang}::Graph";
    require ::($mname);
    my $tracer = ::($mname).new(|%args);

    return $tracer.trace($ebnfAST);
}