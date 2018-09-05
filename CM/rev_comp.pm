# package define
package CM::rev_comp;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(rev_comp);

# get reverse complement of sequence # $rev_comp_sequence = rev_comp ($sequence)
sub rev_comp {
	my $rev = reverse($_[0]); #String rueckwaerts einlesen
	$rev =~tr/ACTGactg/TGACtgac/; #Nucleotide uebersetzen
	return $rev;
}
1;
