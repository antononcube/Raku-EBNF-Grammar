use v6.d;

class EBNF::Actions::Raku::AST {

    has $.name is rw = 'MyEBNFGrammar';
    has $.normalize is rw = True;

    #======================================================
    # Helper methods
    #======================================================

    method to-quoted($s) {
        given $s {
            when $_ ~~ / ^ \" .* \" $ | ^ \' .+ \' $ / { $s }
            default { "\"$s\"" }
        }
    }

    method to-double-quoted($s) {
        given $s {
            when $_ ~~ / ^ \" .* \" $ / { $s }
            when $_ ~~ / ^ \' .+ \' $ / { "\"{ $s.substr(1, *- 1) }\"" }
            default { "\"$s\"" }
        }
    }

    method to-single-quoted($s) {
        given $s {
            when $_ ~~ / ^ \' .* \' $ / { $s }
            when $_ ~~ / ^ \" .+ \" $ / { "\"{ $s.substr(1, *- 1) }\"" }
            default { "'$s'" }
        }
    }

    method to-angle-bracketed($s) { $s ~~ / ^ '<' .* '>' $ / ?? $s !! "<$s>" }

    #======================================================


    method flatten-sequence($x) {
        if $x ~~ Pair && $x.key.starts-with('EBNFSequence') {
            return self.flatten-sequence($x.value[1]).prepend($x.value[0]);
        } else {
            return [$x,];
        }
    };

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
        my $res = $/.values[0].made;
        if $res.Str.contains('EBNFSequencePickLeft') || $res.Str.contains('EBNFSequencePickRight') {
            make $res;
        } else {
            my @res = self.flatten-sequence($res);
            make @res.elems > 1 ?? Pair.new('EBNFSequence', @res.List) !! @res[0];
        }
    }

    method seq-sep($/) { make $/.values[0].made; }
    method seq-sep-comma($/) { make 'EBNFSequence'; }
    method seq-sep-left($/) { make 'EBNFSequencePickLeft'; }
    method seq-sep-right($/) { make 'EBNFSequencePickRight'; }

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
        make Pair.new('EBNFOption', $/.values[0].made);
    }

    method repetition($/) {
        make Pair.new('EBNFRepetition', $/.values[0].made);
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
        make Pair.new('EBNFTerminal', $!normalize ?? self.to-double-quoted($/.Str) !! $/.Str);
    }

    method non-terminal($/) {
        make Pair.new('EBNFNonTerminal', $!normalize ?? self.to-angle-bracketed($/.Str) !! $/.Str);
    }
}