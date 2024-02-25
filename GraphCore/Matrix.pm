package GraphCore::Matrix;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $m = shift;
    my $n = shift;
    my $data = [];
    for (my $i=0; $i < $m; $i++) {
	my $row_vec = [];
	for (my $j=0; $j < $n; $j++) {
	    push(@$row_vec, 0);
	}
	push(@$data, $row_vec);
    }
    my $self = {
	nrows => $m,
	ncols => $n,
	data => $data
    };
    return bless $self, $class;
}

sub clone {
    my $self = shift;
    my $mat = GraphCore::Matrix->new($self->{nrows}, $self->{ncols});
    for (my $r = 0; $r < $self->{nrows}; $r++) {
	for (my $c = 0; $c < $self->{ncols}; $c++) {
	    $mat->{data}->[$r][$c] = $self->{data}->[$r][$c];
	}
    }
    return $mat;
}

sub get_row_vector {
    my $self = shift;
    my $r = shift;
    return $self->{data}->[$r];
}

sub get_column_vector {
    my $self = shift;
    my $c = shift;
    my $cv = [];
    for (my $r = 0; $r < $self->{nrows}; $r++) {
	push(@$cv, $self->{data}->[$r][$c]);
    }
    return $cv;
}

sub mmul {
    my $self = shift;
    my $mat = shift;
    my $target = GraphCore::Matrix->new($self->{nrows}, $mat->{ncols});
    for (my $r = 0; $r < $self->{nrows}; $r++) {
	for (my $c = 0; $c < $mat->{ncols}; $c++) {
	    my $val = 0;
	    for (my $i = 0; $i < $self->{ncols}; $i++) {
		$val += $self->{data}->[$r][$i] * $mat->{data}->[$i][$c];
	    }
	    $target->{data}->[$r][$c] = $val;
	}
    }
    return $target;
}

sub smul {
    my $self = shift;
    my $s = shift;
    my $target = GraphCore::Matrix->new($self->{nrows}, $self->{ncols});
    for (my $r = 0; $r < $self->{nrows}; $r++) {
	for (my $c = 0; $c < $self->{ncols}; $c++) {
	    my $val = $self->{data}->[$r][$c];
	    $target->{data}->[$r][$c] = $s * $val;
	}
    }
    return $target;
}

sub transpose {
    my $self = shift;
    my $target = GraphCore::Matrix->new($self->{ncols}, $self->{nrows});
    for (my $r = 0; $r < $self->{nrows}; $r++) {
	for (my $c = 0; $c < $self->{ncols}; $c++) {
	    my $val = $self->{data}->[$r][$c];
	    $target->{data}->[$c][$r] = $val;
	}
    }
    return $target;
}

sub print {
    my $self = shift;
    my $rows = $self->{data};
    for my $rv (@$rows) {
	print"[",join(" ",@$rv),"]\n";
    }
}


1;
__END__
