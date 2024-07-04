use v6.d;

class EBNF::Actions::WL::FunctionalParsers {

    has $.name is rw = 'MyFP';
    has Str $.prefix is rw  = 'p';
    has Str $.start is rw = 'top';
    has &.modifier is rw = {$_.uc};

    method top-rule-name { self.prefix ~ self.modifier.(self.start) }
    method setup-code { 'Needs["AntonAntonov`FunctionalParsers`"];' }

    method TOP($/) {
        make $/.values[0].made;
    }

    method ebnf($/) {
        my $res ~= $/.values>>.made.join("\n");
        make $res;
    }

    method rule($/) {
        #make "method {$<lhs>.made}(@x) \{ {$<rhs>.made}(@x) \}";
        my $mname = $<lhs>.made.subst(/ ^ '{self.' /, '').subst(/'($_)}' $/, '');
        make "{$mname} = {$<rhs>.made};";
    }

    method sequence($/) {
        make $/.values.elems == 1 ?? $/.values[0].made !! "ParseSequentialComposition[{$/.values>>.made.join(', ')}]";
    }

    method seq-sep($/) { make $/.values[0].made; }
    method seq-sep-comma($/) { make 'ParseSequentialComposition'; }
    method seq-sep-left($/) { make 'ParseSequentialCompositionPickLeft'; }
    method seq-sep-right($/) { make 'ParseSequentialCompositionPickRight'; }

    method sequence-any($/) {
        if $<seq-sep> {
            make "{$<seq-sep>.made}[{$<factor>.made}, {$<sequence-any>.made}]";
        } else {
            make $<factor>.made;
        }
    }

    method sequence-comma($/) {
        if $/.values.elems == 1 {
            make $/.values[0].made;
        } else {
            make "ParseSequentialComposition[{ $/.values>>.made.join(' , ') }]";
        }
    }

    method func-spec($/) {
        make $/.Str;
    }

    method apply($/) {
        make "ParseApply[{$<func-spec>.made}, {$<sequence>.made}]";
    }

    method alternatives($/) {
        make $/.values.elems == 1 ?? $/.values[0].made !! "ParseAlternativeComposition[{$/.values>>.made.join(', ')}]";
    }

    method factor($/) {
        given $<quantifier> {
            when '?' { make "ParseOption[{ $<term>.made }]"; }
            when '+' { make "ParseMany1'{ $<term>.made }]"; }
            when '*' { make "ParseMany[{ $<term>.made }]"; }
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
        make "ParseOption[$res]";
    }

    method repetition($/) {
        my $res = $/.values[0].made;
        make "ParseMany[$res]";
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
        make "ParseSymbol[{$/.Str.subst('\'','"'):g}]";
    }

    method non-terminal($/) {
        make "{self.prefix}" ~ self.modifier.($/.Str.subst(/\s/,'').subst(/^ '<'/,'').subst(/'>' $/,''));
    }
}