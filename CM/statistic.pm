# package define
package CM::statistic;

use warnings;
use strict;


# include module global
use lib '/home/clara/Projekte/CMPERL/'; # search for moduls into cwd


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(mean);


# calculate mean
sub mean {
	my $count = 0;
	my $um = 0;
	my $arr = $_[0];
	foreach (@$arr) {
		$um += $_;
		$count++;
	}
	return ($um/$count);
}



1; # the end
