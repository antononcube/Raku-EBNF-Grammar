use v6.d;

use EBNF::Actions::Raku::Grammar;

class EBNF::Actions::MermaidJS::Graph
        is EBNF::Actions::Raku::Grammar {

    has %.nodes;
    has @.rules;
    has UInt $.altCount;
    has UInt $.seqCount;

    method make-mmd-node(Str $spec) {

        my ($name, $node);

        given $spec {
            when 'alt' {
                $name = "alt{$!altCount++}";
                $node = 'or';
            }

            when 'seq' {
                $name = "seq{$!altCount++}";
                $node = 'and';
            }

            when $_ ~~ / '<' .*? '>' / {
                $name = $spec.substr(1, *- 1);
                $node = "([$name])";
                $name = "NT:{ $name }";
                %!nodes{$name} = $node;
            }

            default {
                $name = $spec.substr(1, *- 1);
                $node = "[$name]";
                $name = "T:{ $name }";
            }
        }

        %!nodes{$name} = $node;

        return $name
    }

    method ebnf($/) {
        my @rules = $/.values>>.made.flat;
        my $res = "graph TD\n\t";
        $res ~= %!nodes.map({ $_.key ~ $_.value }).join("\n\t");
        $res ~= "\n\t";
        $res ~= @rules.join("\n\t");
        make $res;
    }

    method rule($/) {
        my $lhs = self.make-mmd-node("<{$<lhs>.made}>");
        my @terminals = |(-> $x { my $/; $x.match( / ['\'' | '\"'] .*? ['\'' | '\"'] / ):g; $/ }($<rhs>.made));
        my @nonTerminals = |(-> $x { my $/; $x.match( / '<' .*? '>' / ):g; $/ }($<rhs>.made));

        my @res;
        @res.append( @terminals.map({ "$lhs --> {self.make-mmd-node($_.Str)}" }) );
        @res.append( @nonTerminals.map({ "$lhs --> {self.make-mmd-node($_.Str)}" }) );

        make @res;
    }

#`[
    method seq($/) {
        my @b = $/.values>>.made;
        my $op = self.make-mmd-node('seq');
        @!rules.append(@b.map({ "$op --> {self.make-mmd-node($_.Str)}" }));
        make $op;
    }

    method alternatives($/) {
        my @b = $/.values>>.made;
        my $op = self.make-mmd-node('alt');
        @!rules.append(@b.map({ "$op --> {self.make-mmd-node($_.Str)}" }));
        make $op;
    }
]
}