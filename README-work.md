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

Here the obtained Raku grammar is evaluated and used to do a few parsings:  

```perl6
my $gr = ebnf-interpret($ebnf):eval;

.say for <212 89 9090>.map({ $gr.parse($_) });
```

------

## CLI

The package provides a Command Line Interface (CLI) script for parsing EBNF. Here is its usage message:

```shell
ebnf-parse --help
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
