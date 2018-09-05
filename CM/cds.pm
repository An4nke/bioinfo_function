# package define
package CM::cds;

use strict;
use warnings;

# include module global
use lib '/home/clara/Projekte/CMPERL/'; # search for moduls into cwd
use CM::gncttr_global qw($genom $seq $minsize $tmp $model $header $limit %starts %stops);

## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(cds);


sub cds {
	my $starts = shift;
	my $stop = shift;
	my $first = shift;
	my $codons = shift;
	my %cds; # 2>header" => "[ATCG]+"

	# try to find all startcodons before certain stop codon
	foreach (sort {$a <=> $b} keys %$starts) {
		my $start = $_;
		if ($start < $stop && ($stop - $start) >= $minsize) {
			print STDERR "[INFO]\tAnalysis of Position ".($stop + $first)."\n";
			# print CDS
			foreach (sort {$a <=> $b} keys %$codons) {
				if ($_ >= $start && $_ <= $stop) {
					$cds{">".($start + $first)." - ".($stop + $first)} .= $$codons{$_};
				}
			}
		}
	}
	return \%cds;
}
1;

