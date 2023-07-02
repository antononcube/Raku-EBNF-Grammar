use v6.d;

role EBNF::Grammar::Standardish {
    regex letter { <:Ll> | <:Lu> }
    regex digit { \d }
    regex symbol { "[" | "]" | '{' | '}' | '(' | ')' | '<' | '>' | '\'' | '"' | '=' | '|' | '.' | ',' | ';' | '-' | '+' | '*' | '?' | "\n" | "\t" | "\r" | "\f" | "\b" }
    regex character { . }
    regex identifier { <.alpha> [ '-' | <.alnum> ]* }
    regex WS { <ws> }
    regex terminal { '"' <-['"]>+ '"' | '\'' <-['"]>+ '\''  }
    regex non-terminal { '<' <identifier> '>' }
    token terminator { ";" | "." }
    regex parens { '(' <.WS> <rhs> <.WS> ')' }
    regex option { '[' <.WS> <rhs> <.WS> ']' }
    regex repetition { '{' <.WS> <rhs> <.WS> '}' }
    regex term { <parens> | <option> | <repetition> | <terminal> | <non-terminal> }
    token quantifier { '?' | '*' | '+' }
    regex factor { <term> <.WS> <quantifier> | <term> <.WS> }
    token seq-sep-comma { ',' }
    token seq-sep-left { '<&' }
    token seq-sep-right { '&>' }
    token seq-sep { <seq-sep-comma> || <seq-sep-left> || <seq-sep-right> }
    # regex sequence { <sequence-comma> | <sequence-any> }  # This make the parsing too slow
    regex sequence { <sequence-any> }
    regex sequence-any { <.WS> <factor> <.WS> <seq-sep> <.WS> <sequence-any> | <.WS> <factor> <.WS> }
    regex sequence-comma { <.WS> <factor>+ % [ <.WS> <.seq-sep-comma> <.WS> ] <.WS>  }
    regex apply-sep { '<@' }
    regex func-spec { <.alnum>+ | '${' <-[\v]>+ '}' }
    regex apply { <sequence> <.WS> <.apply-sep> <.WS> <func-spec>}
    token alt-sep { '|' }
    regex alternatives { <.WS> [ <sequence> | <apply> ]+ % [<.WS> <.alt-sep> <.WS> ] }
    regex rhs { <alternatives> }
    regex lhs { <non-terminal> }
    token assign-symbol { '=' | ':=' | '::=' }
    regex rule { <lhs> <.WS> <.assign-symbol> <.WS> <rhs> <.WS> <.terminator> }
    regex ebnf { [<.WS> <rule> <.WS>]* }
}