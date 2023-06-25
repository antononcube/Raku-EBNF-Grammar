use v6.d;

class EBNF::Actions::Raku::Grammar {

    has $.name is rw = 'MyEBNFGrammar';

    method TOP($/) {
        make $/.values[0].made;
    }

    method pGRAMMAR($/) {
        my $res = "grammar {self.name} \{\n\t";
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
        if $<pMODIFIER> {
            make "[{ $<pTERM>.made }]{ $<pMODIFIER>.Str }";
        } else {
            make $<pTERM>.made;
        }
    }

    method pTERM($/) {
        make $/.values[0].made;
    }

    method pPARENS($/) {
        make $/.values[0].made;
    }

    method pOPTION($/) {
        my $res = $/.values[0].made;
        make $res.contains(/\s/) ?? "[$res]?" !! "$res?";
    }

    method pREPETITION($/) {
        my $res = $/.values[0].made;
        make $res.contains(/\s/) ?? "[$res]*" !! "$res*";
    }

    method pRHS($/) {
        make $/.values[0].made;
    }

    method pLHS($/) {
        make $/.values[0].made.subst(/^ '<'/, '').subst(/'>' $/, '');
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