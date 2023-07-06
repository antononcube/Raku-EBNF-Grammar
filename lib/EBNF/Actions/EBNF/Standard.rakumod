use v6.d;

use EBNF::Actions::Raku::AST;

class EBNF::Actions::EBNF::Standard
        is EBNF::Actions::Raku::AST {

    method TOP($/) {
        make $/.values[0].made;
    }

    method ebnf($/) {
        make $/.values>>.made.join("\n");
    }

    method rule($/) {
        make "{ $<lhs>.made } = { $<rhs>.made } ;";
    }

    method sequence($/) {
        make $/.values[0].made;
    }

    method sequence-any($/) {
        if $<seq-sep> {
            my $left = $<factor>.made;
            my $right = $<sequence-any>.made;
            given $<seq-sep> {
                when $_<seq-sep-right> {
                    make "$left &> $right";
                }
                when $_<seq-sep-left> {
                    make "$left <& $right";
                }
                default {
                    make "$left , $right";
                }
            }
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
        make "{ $<sequence>.made } <@ \$\{ { $<func-spec>.made } \}";
    }

    method alternatives($/) {
        make $/.values>>.made.join(' | ');
    }

    method factor($/) {
        if $<quantifier> {
            given $<quantifier>.Str.trim {
                when $_ eq '?' {
                    make "[ { $<term>.made } ]";
                }
                when $_ ∈ <* +> {
                    make "\{ { $<term>.made } \}";
                }
            }
        } else {
            make $<term>.made;
        }
    }

    method term($/) {
        make $/.values[0].made;
    }

    method parens($/) {
        make "( {$/.values[0].made} )";
    }

    method option($/) {
        my $res = $/.values[0].made;
        make "[ $res ]";
    }

    method repetition($/) {
        my $res = $/.values[0].made;
        make "\{ $res \}";
    }

    method rhs($/) {
        make $/.values[0].made;
    }

    method lhs($/) {
        make $/.values[0].made;
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
        make "<{ $/.Str }>".subst(/^ '<<'/, '<').subst(/'>>' $/, '>').subst( / \s /, '_', :g);
    }
}