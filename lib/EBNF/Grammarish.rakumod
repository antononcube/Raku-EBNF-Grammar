use v6.d;

role EBNF::Grammarish {
    regex pLETTER { <:Ll> | <:Lu> }
    regex pDIGIT { \d }
    regex pSYMBOL { "[" | "]" | '{' | '}' | '(' | ')' | '<' | '>' | '\'' | '"' | '=' | '|' | '.' | ',' | ';' | '-' | '+' | '*' | '?' | "\n" | "\t" | "\r" | "\f" | "\b" }
    regex pCHARACTER { . }
    regex pIDENTIFIER { <.alpha> <.alnum>* }
    regex pS { \s* }
    regex pTERMINAL { '"' <-['"]>+ '"' | '\'' <-['"]>+ '\''  }
    regex pNONTERMINAL { '<' <pIDENTIFIER> '>' }
    regex pTERMINATOR { ";" | "." }
    regex pPARENS { '(' <.pS> <pRHS> <.pS> ')' }
    regex pOPTION { '[' <.pS> <pRHS> <.pS> ']' }
    regex pREPETITION { '{' <.pS> <pRHS> <.pS> '}' }
    regex pTERM { <pPARENS> | <pOPTION> | <pREPETITION> | <pTERMINAL> | <pNONTERMINAL> }
    token pMODIFIER { '?' | '*' | '+' }
    regex pFACTOR { <pTERM> <.pS> <pMODIFIER> | <pTERM> <.pS> }
    regex pCONCATENATION { <.pS> <pFACTOR>+ % [ <.pS> ',' <.pS> ] <.pS> }
    regex pALTERNATION { <.pS> <pCONCATENATION>+ % [<.pS> "|" <.pS> ] }
    regex pRHS { <pALTERNATION> }
    regex pLHS { <pNONTERMINAL> }
    token pASSIGN { '=' | ':=' | '::=' }
    regex pRULE { <pLHS> <.pS> <.pASSIGN> <.pS> <pRHS> <.pS> <.pTERMINATOR> }
    regex pGRAMMAR { [<.pS> <pRULE> <.pS>]* }
}