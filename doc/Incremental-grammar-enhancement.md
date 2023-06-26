# Incremental grammar enhancement

## Introduction

This document demonstrates how to use Large Language Models (LLMs) and Extended Backus-Naur Form (EBNF)
to generate and incrementally develop grammars for Domain Specific Languages (DSLs).

-------

## Procedure outline

### If LLM speaks Raku

*TBD...*

### Using BNF

```mermaid
graph TD
    Start([Start])
    End([End])
    LLM[[LLM access<br>package]]
    ChatGPT{{ChatGPT}}
    PaLM{{PaLM}}
    ReqBNF[[Request BNF<br>generation]]
    ReqVar[[Request sentences<br>variations]]
    RSentences>Random sentences]
    ComeUpRSentences[Come up with<br>random sentences]
    GenRSentences[Generate<br>random sentences]
    CodeBNF>BNF]
    RakuObj(Raku object)
    ParseBNF[Parse BNF]
    LargeEnoughQ{Is the grammar<br/>large enough?}
    Start --> ComeUpRSentences
    ComeUpRSentences --> ReqBNF
    RSentences -.-> ReqBNF 
    ReqBNF <-.-> LLM
    ReqBNF -.-> CodeBNF
    CodeBNF -.-> ParseBNF 
    ParseBNF -.-> RakuObj
    ParseBNF --> GenRSentences
    RakuObj -.-> GenRSentences
    GenRSentences -.-> RSentences
    GenRSentences --> LargeEnoughQ
    LargeEnoughQ --> |yes|End
    LargeEnoughQ --> |no|ReqVar
    ReqVar --> ReqBNF
    ReqVar <-.-> LLM
    LLM -.-> ChatGPT
    LLM -.-> PaLM
```

1. Come up with sentences from a certain Domain Specific Language (DSL).
2. Request a certain Large Language Model (LLM) -- for example, ChatGPT or PaLM -- to generate a corresponding grammar in Backus-Naur Form (BNF).
3. Using the obtained BNF string create a corresponding Raku object that can be used generate new random sentences. One of:
   - Raku class for "FunctionalParsers"
   - Raku grammar
4. With Raku object generate a set of random sentences.
5. Request LLM to come up with, say, 5-10 variations of each sentence.
6. Request BNF for the new, enhanced set of sentences.
7. Is the obtained grammar large or comprehensive enough?
   - If not then go to step 2.
   - If yes finish.

-------

## Setup

Here are the packages we are going to use:

```perl6
use Grammar::TokenProcessing;
use EBNF::Grammar;
use FunctionalParsers;
use WWW::OpenAI;
use WWW::PaLM;
```
```
# (Any)
```

-------

## Several iterations

```perl6
my @startSentences = [
  'I hate R', 'I love WL', 'We hate WL', 'I love R', 
  'I love Julia', 'I hate R', 'We hate R', 'I hate WL' 
];
```
```
# [I hate R I love WL We hate WL I love R I love Julia I hate R We hate R I hate WL]
```

```perl6
my $request1 = "Generate BNF grammar for the sentences: {@startSentences.join(', ')}";
my $variations1 = palm-generate-text($request1, format=>'values', temperature => 0.15, max-output-tokens => 600);
$variations1
```
```
# <sentence> ::= <subject> <verb> <object>
# <subject> ::= I | We
# <verb> ::= hate | love
# <object> ::= R | WL | Julia
```

```perl6
my $variations2 = $variations1.lines.grep({ EBNF::Grammar::Relaxed.parse($_, rule => 'rule') }).join("\n");
```
```
# <sentence> ::= <subject> <verb> <object>
# <subject> ::= I | We
# <verb> ::= hate | love
# <object> ::= R | WL | Julia
```

```perl6
my $grCode = ebnf-interpret($variations2, style => 'inverted', name => 'First');
say $grCode;
```
```
# grammar First {
# 	regex sentence { <subject> <verb> <object> }
# 	regex subject { 'I' | 'We' }
# 	regex verb { 'hate' | 'love' }
# 	regex object { 'R' | 'WL' | 'Julia' }
# }
```

```perl6
my $gr = ebnf-interpret($variations2, style => 'inverted', name=>'First'):eval;
```
```
# (First)
```

```perl6
my $grTopRule = "<{grammar-top-rule($grCode)}>";
say $grTopRule;
```
```
# <sentence>
```

```perl6
my @genSentences = random-sentence-generation($gr, $grTopRule) xx 12;

.say for @genSentences;
```
```
# I hate Julia
# We love Julia
# We hate Julia
# I love WL
# I hate R
# We love WL
# We hate WL
# I love Julia
# I hate R
# I love R
# I hate WL
# I love R
```

-------

## References

### Articles

### Packages, repositories