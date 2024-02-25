package GraphCore::Function;

use strict;
use warnings;
use JSON::PP;

sub new {
    my $class = shift;
    my $self = {
    };
    return bless $self, $class;
}

sub clone {
    my $self = shift;
    my $json = JSON::PP->new->utf8;
    my $json_text = $json->encode($self);
    my $json_data = $json->decode($json_text);
    my $clone = GraphCore::Function->new;
    for my $s (keys @$json_data) {
	$clone->{$s} = $json_data->{$s};
    }
    return $clone;
}

sub set_xy {
    my $self = shift;
    my $x = shift;
    my $y = shift;
    #print $x, $y, "\n";
    my @keys = keys %$self;
    my $s = @keys; $s++;
    $self->{$s} = {
	x => $x,
	y => $y
    };
}

sub get {
    my $self = shift;
    my $h = shift;
    for my $s (keys %$self) {
	my $x = $self->{$s}->{x};
	my $y = $self->{$s}->{y};
	my $nx = @$x;
	for (my $i = 0; $i < $nx; $i++) {
	    if ($h == $x->[$i]) {
		return $y->[$i];
	    }
	    if ($i < $nx - 1 && $x->[$i] < $h && $h < $x->[$i+1]) {
		my $x1 = $x->[$i];
		my $y1 = $y->[$i];
		my $x2 = $x->[$i+1];
		my $y2 = $y->[$i+1];
		my $a = ($y2-$y1) / ($x2-$x1);
		my $k = $y1 - $a*$x1;
		my $v = $a*($h-$x1) + $k;
		return $v;
	    }
	}
    }
    return;
}

sub get_dydx {
    my $self = shift;
    my $h = shift;
    for my $s (keys %$self) {
	my $x = $self->{$s}->{x};
	my $y = $self->{$s}->{y};
	my $nx = @$x;
	for (my $i = 0; $i < $nx; $i++) {
	    if ($h == $x->[$i]) {
		if (0 < $i && $i < $nx-1) {
		    my $k0 = ($y->[$i] - $y->[$i-1]) / ($x->[$i] - $x->[$i-1]);
		    my $k1 = ($y->[$i+1] - $y->[$i]) / ($x->[$i+1] - $x->[$i]);
		    my $k = ($k0 + $k1) / 2;
		    return $k;
		}
		elsif ($i == 0) {
		    my $k = ($y->[$i+1] - $y->[$i]) / ($x->[$i+1] - $x->[$i]);
		    return $k;
		}
		else {
		    my $k = ($y->[$i] - $y->[$i-1]) / ($x->[$i] - $x->[$i-1]);
		    return $k;
		}
	    }
	    elsif ($i < $nx - 1 && $x->[$i] < $h && $h < $x->[$i+1]) {
		my $k = ($y->[$i+1] - $y->[$i]) / ($x->[$i+1] - $x->[$i]);
		return $k;
	    }
	}
    }
    return undef;
}

sub calc_single_integral {
    my $self = shift;
    my $I = shift;
    my $nI = @$I;
    my $startI = $I->[0];
    my $endI = $I->[$nI-1];
    for my $s (keys %$self) {
	my $X = $self->{$s}->{x};
	my $Y = $self->{$s}->{y};
	my $nX = @$X;
	my $startX = $X->[0];
	my $endX = $X->[$nX-1];
	if ($startX <= $startI && $endI <= $endX) {
	    my $new_series = [];
	    for (my $i = 0; $i < $nX; $i++) {
		if ($i < $nX-1 && $X->[$i] <= $startI && $startI < $X->[$i+1]) {
		    push(@$new_series, $startI);
		}
		elsif ($i == $nX-1 && $X->[$i-1] < $endI && $endI <= $X->[$i]) {
		    push(@$new_series, $endI);
		}
		else {
		    push(@$new_series, $X->[$i]);
		}
	    }
	    my $num_new_series = @$new_series;
	    my $value = 0;
	    for (my $i = 0; $i < $num_new_series-1; $i++) {
		my $x1 = $new_series->[$i];
		my $y1 = $self->get($x1) ;
		my $x2 = $new_series->[$i+1];
		my $y2 = $self->get($x2) ;
		my $a = ($y2 - $y1) / ($x2 - $x1);
		my $k = $y1 - $a*$x1;
		my $v = $a/2*($x2**2-$x1**2) + $k*($x2-$x1);
		#print"\\int_$a*x + $k ($x1, $x2) = $v\n";
		$value += $v;
	    }
	    return $value;
	}
    }
    return;
}

sub calc_integral {
    my $self = shift;
    my @intervals = @_;
    my $value = 0;
    for my $I (@intervals) {
	my $v = $self->calc_single_integral($I);
	return unless defined $v;
	$value += $v;
    }
    return $value;
}


1;
__END__
