use v6.d;

class EBNF::Actions::Raku::AST {

    has $.name is rw = 'MyEBNFGrammar';

    method TOP($/) {
        make $/.values[0].made;
    }

    method ebnf($/) {
        make Pair.new('EBNF', $/.values>>.made);
    }

    method rule($/) {
        make Pair.new('EBNFRule', Pair.new($<lhs>.made, $<rhs>.made));
    }

    method sequence($/) {
        make $/.values[0].made;
    }

    method seq-sep($/) { make $/.values[0].made; }
    method seq-sep-comma($/) { make 'EBNFSequence'; }
    method seq-sep-left($/) { make 'EBNFSequencePickLeft'; }
    method seq-sep-right($/) { make 'EBNFSequencePicRight'; }

    method sequence-any($/) {
        if $<seq-sep> {
            make Pair.new($<seq-sep>.made, ($<factor>.made, $<sequence-any>.made));
        } else {
            make $<factor>.made;
        }
    }

    method sequence-comma($/) {
        my $res = $/.values>>.made;
        if $res ~~ Positional && $res.elems > 1 {
            make Pair.new('EBNFSequence', $res);
        } else {
            make $res.head;
        }
    }

#    method sequence-left($/) {
#        my $res = $/.values>>.made;
#        if $res ~~ Positional && $res.elems > 1 {
#            make Pair.new('EBNFSequencePickLeft', $res);
#        } else {
#            make $res.head;
#        }
#    }
#
#    method sequence-right($/) {
#        my $res = $/.values>>.made;
#        if $res ~~ Positional && $res.elems > 1 {
#            make Pair.new('EBNFSequencePickRight', $res);
#        } else {
#            make $res.head;
#        }
#    }

    method func-spec($/) {
        make $/.Str;
    }

    method apply($/) {
        make Pair.new('EBNFApply', ($<func-spec>.made, $<sequence>.made));
    }

    method alternatives($/) {
        my $res = $/.values>>.made;
        if $res ~~ Positional && $res.elems > 1 {
            make Pair.new('EBNFAlternatives', $res);
        } else {
            make $res.head;
        }
    }

    method factor($/) {
        if $<quantifier> {
            make "[{ $<term>.made }]{ $<quantifier>.Str }";
        } else {
            make $<term>.made;
        }
    }

    method term($/) {
        make $/.values[0].made;
    }

    method parens($/) {
        make $/.values[0].made;
    }

    method option($/) {
        make Pair.new('EBNFOption', $/.made);
    }

    method repetition($/) {
        make Pair.new('EBNFRepetition', $/.made);
    }

    method rhs($/) {
        make $/.values[0].made;
    }

    method lhs($/) {
        make $/.values[0].made.value;
    }

    method identifier($/) {
        make $/.Str;
    }

    method terminal($/) {
        make Pair.new('EBNFTerminal', $/.Str);
    }

    method non-terminal($/) {
        make Pair.new('EBNFNonTerminal', $/.Str);
    }
}