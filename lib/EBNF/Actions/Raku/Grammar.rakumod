use v6.d;

class EBNF::Actions::Raku::Grammar {

    method TOP($/) {
        make $/.values[0].made;
    }

    method pGRAMMAR($/) {
        my $res = "grammar MyNewGrammar \{\n\t";
        $res ~= $/.values>>.made.join("\n\t");
        $res ~= "\n}";
        make $res;
    }

    method pRULE($/) {
        make "regex {$<pLHS>.made} \{ {$<pRHS>.made} \}";
    }

    method pCONCATENATION($/) {
        make $/.values>>.made.join(' ');
    }

    method pALTERNATION($/) {
        make $/.values>>.made.join(' | ');
    }

    method pFACTOR($/) {
        make $<pTERM>>>.made;
    }

    method pTERM($/) {
        make $/.values[0].made;
    }

    method pRHS($/) {
        make $/.values[0].made;
    }

    method pLHS($/) {
        make $/.values[0].made;
    }

    method pIDENTIFIER($/) {
        make $/.Str;
    }

    method pTERMINAL($/) {
        make $/.Str;
    }

    method pNONTERMINAL($/) {
        make $/.Str;
    }
}