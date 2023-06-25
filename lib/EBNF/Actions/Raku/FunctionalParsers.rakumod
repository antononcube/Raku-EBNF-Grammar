use v6.d;

class EBNF::Actions::Raku::FunctionalParsers {

    has $.name is rw = 'MyEBNFClass';
    has Str $.prefix is rw  = 'p';
    has Str $.start is rw = 'top';
    has &.modifier is rw = {$_.uc};

    method top-rule-name { self.prefix ~ self.modifier.(self.start) }
    method setup-code { 'use FunctionalParsers;' }

    method TOP($/) {
        make $/.values[0].made;
    }

    method ebnf($/) {
        my $res = "class {self.name} \{\n\t";
        $res ~= $/.values>>.made.join("\n\t");
        $res ~= "\n\thas \&.parser is rw = -> @x \{ self.{self.top-rule-name}(@x) \};";
        $res ~= "\n}";
        make $res;
    }

    method rule($/) {
        #make "method {$<lhs>.made}(@x) \{ {$<rhs>.made}(@x) \}";
        my $mname = $<lhs>.made.subst(/ ^ '{self.' /, '').subst(/'($_)}' $/, '');
        make "method {$mname}(@x) \{ {$<rhs>.made}(@x) \}";
    }

    method sequence($/) {
        make $/.values.elems == 1 ?? $/.values[0].made !! "sequence({$/.values>>.made.join(', ')})";
    }

    method alternatives($/) {
        make $/.values.elems == 1 ?? $/.values[0].made !! "alternatives({$/.values>>.made.join(', ')})";
    }

    method factor($/) {
        given $<quantifier> {
            when '?' { make "option({ $<term>.made })"; }
            when '+' { make "many1({ $<term>.made })"; }
            when '*' { make "many({ $<term>.made })"; }
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
        make "option($res)";
    }

    method repetition($/) {
        my $res = $/.values[0].made;
        make "many($res)";
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
        make "symbol({$/.Str})";
    }

    method non-terminal($/) {
        #make "\{self.{$/.Str.subst(/^ '<'/, '').subst(/'>' $/, '')}(\$_)\}";
        make '{' ~ "self.{self.prefix}" ~ self.modifier.($/.Str.subst(/\s/,'').subst(/^ '<'/,'').subst(/'>' $/,'')) ~ '($_)}';
    }
}