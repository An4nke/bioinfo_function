# package define
package CM::arr;


use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(break_down);

# separate n elemente of array into 2 (1/2 n elements per array) # my ($old, $new) = break_down \@AScca1dir
sub break_down {
	my $arr = $_[0]; # array ref for splitting
	my @arr = @$arr; # save array into new array -> avoid destroying old one!
	my @set; 
	my $n = @$arr; # length of array
	for (my $i = 1; $i <= $n/2; $i++) {
		push @set, splice(@arr, int (rand (scalar @arr)), 1); # extract random array element
		#print $i."\t".scalar @$arr."\n";
	}
	return (\@set, \@arr); # return 2x 1/2 n arrays
}


1;
