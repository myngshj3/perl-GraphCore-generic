package GraphCore::Simulator;

use strict;
use warnings;
require GraphCore::Matrix;


sub new {
    my $class = shift;
    my $graph = shift;
    my $self = {
	graph => $graph->clone,
	dt => 0.5
    };
    return bless $self, $class;
}

sub create_adjacent_matrix {
    my $self = shift;
    my $attr_name = shift;
    my $dt = $self->{dt};
    my $nodes = $self->{graph}->{nodes};
    my $m = @$nodes;
    my $mat = GraphCore::Matrix->new($m, $m);
    my $edges = $self->{edges};
    foreach my $e (keys %$edges) {
	my $attr = $edges->{$e}->{$attr_name};
	my @n = split(",", $e);
	$mat->[$n[0]][$n[1]] = $attr * $dt;
    }
    return $mat;
}

sub create_velocity_matrix {
    my $self = shift;
    my $index = shift;
    my $nodes = $self->{graph}->{nodes};
    my @node_ids = keys(%$nodes);
    my $m = @node_ids;
    my $edges = $self->{graph}->{edges};
    my $M = GraphCore::Matrix->new($m, $m);
    for my $e (keys %$edges) {
	my @n = split(",", $e);
	$M->{data}->[$n[0]][$n[1]] = $edges->{$e}->{results}->[$index];
    }
    return $M;
}

sub create_src_node_value_matrix {
    my $self = shift;
    my $index = shift;
    my $nodes = $self->{graph}->{nodes};
    my @node_ids = keys(%$nodes);
    my $m = @node_ids;
    my $S = GraphCore::Matrix->new($m, $m);
    for (my $c = 0; $c < $m; $c++) {
	my $v = $nodes->{$c}->{results}->[$index];
	for (my $r = 0; $r < $m; $r++) {
	    $S->{data}->[$r][$c] = $v;
	}
    }
    return $S;
}

sub get_node_value_vector {
    my $self = shift;
    my $index = shift;
    my $nodes = $self->{graph}->{nodes};
    my $vec = [];
    for my $n (sort(keys %$nodes)) {
	push(@$vec, $nodes->{$n}->{results}->[$index]);
    }
    return $vec;
}

sub compute_dst_node_diff_array {
    my ($self, $M, $S) = @_;
    my $T = $M->mmul($S);
    my $V = [];
    for (my $c = 0; $c < $T->{ncols}; $c++) {
	my $val = 0;
	for (my $r = 0; $r < $T->{nrows}; $r++) {
	    $val += $T->{data}->[$r][$c];
	}
	push(@$V, $val);
    }
    return $V;
}

sub set_velocity_function {
    my $self = shift;
    my $e = shift;
    my $f = shift;
    $self->{graph}->{edges}->{$e}->{function} = $f;
}

sub simulate {
    my $self = shift;
    my $startI = shift;
    my $endI = shift;
    my $attr_name = shift;
    my $stopper = shift;
    my $dt = $self->{dt};
    my $nodes = $self->{graph}->{nodes};
    my $edges = $self->{graph}->{edges};
    # setup simulation result record area.
    for my $n (keys %$nodes) {
	$nodes->{$n}->{results} = [$nodes->{$n}->{$attr_name}];
    }
    for my $e (keys %$edges) {
	my $f = $edges->{$e}->{function};
	my $v = $f->get($startI);
	$edges->{$e}->{results} = [ $v ];
    }
    # simulate while in assigned interval.
    my @node_ids = keys(%$nodes);
    my $m = @node_ids;
    for (my ($i, $t) = (0, $startI); $t <= $endI-$dt; $t += $dt, $i++) {
	my $S = $self->get_node_value_vector($i);
	#print"S(",$i,"):\n";
	#print"[",join(" ", @$S),"]\n";
	my $M = $self->create_velocity_matrix($i);
	#print"M(",$i,"):\n";
	#$M->print;
	my $dD = $M->smul($dt);
	#print"dD(",$i,"):\n";
	#$dD->print;
	for (my $row = 0; $row < $m; $row++) {
	    for (my $col = 0; $col < $m; $col++) {
		my $dd = $dD->{data}->[$row][$col];
		$S->[$row] -= $dd;
		$S->[$col] += $dd;
	    }
	}
	for (my $i = 0; $i < $m; $i++) {
	    my $results = $nodes->{$i}->{results};
	    push(@$results, $S->[$i]);
	}
	for my $e (keys %$edges) {
	    my $f = $edges->{$e}->{function};
	    my $results = $edges->{$e}->{results};
	    my $v = $f->get($t + $dt);
	    push(@$results, $v);
	}
    }
}


1;
__END__
