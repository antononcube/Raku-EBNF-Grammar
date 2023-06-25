use v6.d;

role EBNF::Grammar::Standardish {
    regex letter { <:Ll> | <:Lu> }
    regex digit { \d }
    regex symbol { "[" | "]" | '{' | '}' | '(' | ')' | '<' | '>' | '\'' | '"' | '=' | '|' | '.' | ',' | ';' | '-' | '+' | '*' | '?' | "\n" | "\t" | "\r" | "\f" | "\b" }
    regex character { . }
    regex identifier { <.alpha> <.alnum>* }
    regex WS { <ws> }
    regex terminal { '"' <-['"]>+ '"' | '\'' <-['"]>+ '\''  }
    regex non-terminal { '<' <identifier> '>' }
    regex terminator { ";" | "." }
    regex parens { '(' <.WS> <rhs> <.WS> ')' }
    regex option { '[' <.WS> <rhs> <.WS> ']' }
    regex repetition { '{' <.WS> <rhs> <.WS> '}' }
    regex term { <parens> | <option> | <repetition> | <terminal> | <non-terminal> }
    token modifier { '?' | '*' | '+' }
    regex factor { <term> <.WS> <modifier> | <term> <.WS> }
    regex sequence { <.WS> <factor>+ % [ <.WS> ',' <.WS> ] <.WS> }
    regex alternatives { <.WS> <sequence>+ % [<.WS> "|" <.WS> ] }
    regex rhs { <alternatives> }
    regex lhs { <non-terminal> }
    token assign-symbol { '=' | ':=' | '::=' }
    regex rule { <lhs> <.WS> <.assign-symbol> <.WS> <rhs> <.WS> <.terminator> }
    regex ebnf { [<.WS> <rule> <.WS>]* }
}