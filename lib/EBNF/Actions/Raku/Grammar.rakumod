use v6.d;

class EBNF::Actions::Raku::Grammar {

    has $.name is rw = 'MyEBNFGrammar';

    method TOP($/) {
        make $/.values[0].made;
    }

    method ebnf($/) {
        my $res = "grammar {self.name} \{\n\t";
        $res ~= $/.values>>.made.join("\n\t");
        $res ~= "\n}";
        make $res;
    }

    method rule($/) {
        make "regex {$<lhs>.made} \{ {$<rhs>.made} \}";
    }

    method sequence($/) {
        make $/.values>>.made.join(' ');
    }

    method alternatives($/) {
        make $/.values>>.made.join(' | ');
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
        my $res = $/.values[0].made;
        make $res.contains(/\s/) ?? "[$res]?" !! "$res?";
    }

    method repetition($/) {
        my $res = $/.values[0].made;
        make $res.contains(/\s/) ?? "[$res]*" !! "$res*";
    }

    method rhs($/) {
        make $/.values[0].made;
    }

    method lhs($/) {
        make $/.values[0].made.subst(/^ '<'/, '').subst(/'>' $/, '');
    }

    method identifier($/) {
        make $/.Str;
    }

    method terminal($/) {
        make $/.Str;
    }

    method non-terminal($/) {
        make $/.Str;
    }
}