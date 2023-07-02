use v6.d;

class EBNF::Actions::Raku::Grammar {

    has $.name is rw = 'MyEBNFGrammar';
    has $.rule-type is rw = 'regex';

    method TOP($/) {
        make $/.values[0].made;
    }

    method ebnf($/) {
        my $res = "grammar { self.name } \{\n\t";
        $res ~= $/.values>>.made.join("\n\t");
        $res ~= "\n}";
        make $res;
    }

    method rule($/) {
        make "{self.rule-type} { $<lhs>.made } \{ { $<rhs>.made } \}";
    }

    method sequence($/) {
        make $/.values[0].made;
    }

    method sequence-any($/) {
        if $<seq-sep> {
            my $left = $<factor>.made;
            my $right = $<sequence-any>.made;
            given $<seq-sep> {
                when $_<seq-sep-right> && $<factor><term><non-terminal> { $left = $left.subst(/ ^ '<'/, '<.') }
                when $_<seq-sep-left> && $<sequence-any><factor><term><non-terminal> { $right = $right.subst(/ ^ '<'/,
                        '<.') }
            }
            make [$left, $right].join(' ');
        } else {
            make $<factor>.made;
        }
    }

    method sequence-comma($/) {
        make $/.values>>.made.join(' ');
    }

    method func-spec($/) {
        make $/.Str;
    }

    method apply($/) {
        make "{ $<sequence>.made }\nmake \{{ $<func-spec>.made }\}";
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
        my $res = $/.Str;
        make do given $res {
            when $_ ~~ /^ <-['"]>+ $/ { "'$_'" }
            default { $_ }
        }
    }

    method non-terminal($/) {
        make "<{ $/.Str }>".subst(/^ '<<'/, '<').subst(/'>>' $/, '>');
    }
}