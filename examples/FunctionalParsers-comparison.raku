#!/usr/bin/env raku
use v6.d;

use EBNF::Grammar;
use EBNF::Grammar::Standardish;
use FunctionalParsers::EBNF;

my $ebnf1 = q:to/END/;
<top> = <a> | <b> ;
<a> = 'a' , { 'A' };
<b> = 'b' | 'B' , [ '1' ] ;
END

say '=' x 120;

my $res2 = ebnf-interpret($ebnf1, actions => 'FunctionalParsers', name => "FP");

say "EBNF::Grammar :\n";
say $res2;

say '-' x 120;

my $res3 =  parse-ebnf($ebnf1, <CODE>, target => 'Raku::Class').head.tail;
say "FunctionalParsers :\n";
say $res3;

say '-' x 120;

say 'Same class code:';
say $res2 eq $res3;

say '=' x 120;

my $res4 = ebnf-interpret($ebnf1, actions => 'WL::FunctionalParsers', name => "FP"):relaxed;

say "EBNF::Grammar -> WL::FunctionalParsers :\n";
say $res4;

say '-' x 120;

my @res5 = parse-ebnf($ebnf1, <CODE>, target => 'WL::Code').head.tail;
say "FunctionalParsers -> WL::Code :\n";
.say for @res5;

say '-' x 120;

say 'Same class code:';
say $res4.trim eq @res5.join("\n").trim;
