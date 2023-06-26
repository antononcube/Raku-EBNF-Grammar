# EBNF::Grammar Raku package

## Introduction

Raku package for Extended Backus-Naur Form (EBNF) parsing and interpretation.

The grammar follows the description of the Wikipedia entry 
["Extended Backus–Naur form"](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form), [Wk1],
which refers the *proposed* ISO/IEC 14977 standard, by R. S. Scowen, page 7, table 1. [RS1, ISO1].

### Motivation

The main motivation for this package is to have:
- Multiple EBNF styles parsed
- Grammar generation for multiple languages

I considered extending ["Grammar::BNF"](https://raku.land/github:tadzik/Grammar::BNF), 
but ultimately decided that "Grammar::BNF" needs too much refactoring for my purposes,
and, well, it is for BNF not EBNF.


------

## Installation

From [Zef ecosystem](https://raku.land):

```
zef install EBNF::Grammar;
```

From GitHub:

```
zef install https://github.com/antononcube/Raku-EBNF-Grammar.git
```

------

## Usage examples

Here is an EBNF grammar for integers and its interpretation into a Raku grammar:

```perl6
use EBNF::Grammar;

my $ebnf = q:to/END/;
<digit> = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' ;
<integer> = <digit> , { <digit> } ;
<TOP> = <integer> ;
END

ebnf-interpret($ebnf);
```
```
# grammar EBNF_1687748357_612614 {
# 	regex digit { '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' }
# 	regex integer { <digit> <digit>* }
# 	regex TOP { <integer> }
# }
```

Here the obtained Raku grammar is evaluated and used to do a few parsings:  

```perl6
my $gr = ebnf-interpret($ebnf):eval;

.say for <212 89 9090>.map({ $gr.parse($_) });
```
```
# ｢212｣
#  integer => ｢212｣
#   digit => ｢2｣
#   digit => ｢1｣
#   digit => ｢2｣
# ｢89｣
#  integer => ｢89｣
#   digit => ｢8｣
#   digit => ｢9｣
# ｢9090｣
#  integer => ｢9090｣
#   digit => ｢9｣
#   digit => ｢0｣
#   digit => ｢9｣
#   digit => ｢0｣
```

------

### Random sentence generation

Random sentences of grammars given in EBNF can be generated with additional help of the package 
["Grammar::TokenProcessing"](https://github.com/antononcube/Raku-Grammar-TokenProcessing), [AAp2].

Here is an EBNF grammar:

```perl6
my $ebnfCode = q:to/END/;
<statement> = <who> , <verb> , <lang> ;
<who> = 'I' | 'We' ;
<verb> = [ 'really' ] , ( 'love' | 'hate' | { '♥️' } | '🤮' );
<lang> = 'Julia' | 'Perl' | 'Python' | 'R' | 'WL' ; 
END
```
```
# <statement> = <who> , <verb> , <lang> ;
# <who> = 'I' | 'We' ;
# <verb> = [ 'really' ] , ( 'love' | 'hate' | { '♥️' } | '🤮' );
# <lang> = 'Julia' | 'Perl' | 'Python' | 'R' | 'WL' ;
```

Here is the corresponding Raku grammar:

```perl6, result=asis, output-prompt=NONE, output-lang=perl6
ebnf-interpret($ebnfCode, name=>'LoveHateProgLang');
```
```perl6
grammar LoveHateProgLang {
	regex statement { <who> <verb> <lang> }
	regex who { 'I' | 'We' }
	regex verb { 'really'? 'love' | 'hate' | '♥️'* | '🤮' }
	regex lang { 'Julia' | 'Perl' | 'Python' | 'R' | 'WL' }
}
```

Here we generate random sentences:

```perl6
use Grammar::TokenProcessing;

my $gr = ebnf-interpret($ebnfCode, name=>'LoveHateProgLang'):eval;

.say for random-sentence-generation($gr, '<statement>') xx 12;
```
```
# We really love Perl
# We ♥️ WL
# We hate Julia
# We hate Perl
# We really love Python
# We hate WL
# We hate Python
# We really love Julia
# I hate Perl
# We love R
# I ♥️ WL
# I ♥️ Python
```

------

## CLI

The package provides a Command Line Interface (CLI) script for parsing EBNF. Here is its usage message:

```shell
ebnf-parse --help
```
```
# Usage:
#   ebnf-parse <ebnf> [-t|--target=<Str>] [--name|--parser-name=<Str>] [-s|--style=<Str>] -- Generates a parser code for a given EBNF grammar.
#   
#     <ebnf>                        EBNF text.
#     -t|--target=<Str>             Target. [default: 'Raku::Grammar']
#     --name|--parser-name=<Str>    Parser name. [default: 'Whatever']
#     -s|--style=<Str>              EBNF style, one of 'Standard', 'Inverted', 'Relaxed', or 'Whatever'. [default: 'Standard']
```


------

## Implementation notes

1. The first version of "EBNF::Grammar::Standardish" was *generated* with "FunctionalParsers", [AAp1], using the EBNF grammar (given in EBNF) in [Wk1].
2. Refactored `<term>` (originally `<pTERM>`) into separate parenthesized, optional, repeated specs.
   - This corresponds to the design in "FunctionalParsers". 
3. Tokens and regexes were renamed. (More concise, easier to read names.)
4. Implemented the "relaxed" version of the standard EBNF.

------

## TODO

- [ ] TODO Parsing of EBNF
    - [ ] TODO Sequence-pick-left, `<&`
    - [ ] TODO Sequence-pick-right, `&>` 
    - [ ] TODO "Named" tokens
        - [ ] `'_?StringQ'` or `'_String'`
        - [ ] `'_WordString'`, `'_LetterString'`, and `'_IdentifierString'`
        - [ ] `'_?NumberQ'` and `'_?NumericQ'`
        - [ ] `'_Integer'`
        - [ ] `'Range[*from*, *to*]'`
- [ ] TODO Interpreters of EBNF
    - [ ] TODO Java
        - [ ] TODO ["funcj.parser"](https://github.com/typemeta/funcj/tree/master/parser)
    - [ ] TODO Scala
        - [ ] TODO built-in
        - [ ] TODO [parsley](https://github.com/j-mie6/parsley)
    - [ ] MAYBE Python
    - [ ] TODO Raku
        - [X] DONE Grammar
        - [X] DONE FunctionalParsers
        - [ ] TODO MermaidJS
        - [ ] Other EBNF styles
    - [ ] TODO WL
        - [X] DONE FunctionalParsers, [AAp1, AAp2]
        - [ ] TODO GrammarRules
- [X] DONE CLI

------

## References

### Articles

[Wk1] Wikipedia entry, ["Extended Backus–Naur form"](https://en.wikipedia.org/wiki/Extended_Backus–Naur_form).

[RS1] Roger S. Scowen: Extended BNF — A generic base standard. Software Engineering Standards Symposium 1993.

[ISO1] [ISO/IEC 14977:1996](https://www.iso.org/standard/26153.html).

### Packages, repositories

[AAp1] Anton Antonov,
[FunctionParsers Raku package](https://github.com/antononcube/Raku-FunctionalParsers),
(2023),
[GitHub/antononcube](https://github.com/antononcube).

[AAp2] Anton Antonov,
[Grammar::TokenProcessing Raku package](https://github.com/antononcube/Raku-Grammar-TokenProcessing),
(2022-2023),
[GitHub/antononcube](https://github.com/antononcube).
