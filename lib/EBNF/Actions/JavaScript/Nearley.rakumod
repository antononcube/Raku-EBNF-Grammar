use v6.d;

class EBNF::Actions::JavaScript::Nearly {

    has $.name is rw = 'MyFP';
    has Str $.prefix is rw  = 'p';
    has Str $.start is rw = 'top';
    has &.modifier is rw = {$_.uc};

    method top-rule-name { self.prefix ~ self.modifier.(self.start) }
    method setup-code { '' }

    method TOP($/) {
        make $/.values[0].made;
    }

    method ebnf($/) {
        my $res ~= $/.values>>.made.join("\n\n");
        make $res;
    }

    method rule($/) {
        my $mname = $<lhs>.made.subst(/ ^ '{self.' /, '').subst(/'($_)}' $/, '');
        make "{$mname} -> {$<rhs>.made}";
    }

    method sequence($/) {
        make $/.values.elems == 1 ?? $/.values[0].made !! $/.values>>.made.join(' ');
    }

    method func-spec($/) {
        make $/.Str;
    }

    method apply($/) {
        make $<sequence>.made ~ '{% ' ~ $<func-spec>.made ~ ' %}';
    }

    method alternatives($/) {
        make $/.values.elems == 1 ?? $/.values[0].made !! $/.values>>.made.join(' | ');
    }

    method factor($/) {
        given $<quantifier> {
            when '?' { make "$<term>.made:?"; }
            when '+' { make "$<term>.made:+"; }
            when '*' { make "null | $<term>.made:+"; }
            default { make $<term>.made; }
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
        make "$res:?";
    }

    method repetition($/) {
        my $res = $/.values[0].made;
        make "$res:+";
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
        make '"' ~ $/.Str.subst('\'','"', :g) ~ '"';
    }

    method non-terminal($/) {
        make "{self.prefix}" ~ self.modifier.($/.Str.subst(/\s/,'').subst(/^ '<'/,'').subst(/'>' $/,''));
    }
}
