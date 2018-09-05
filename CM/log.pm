# package define
package CM::log;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(seqout);


# write sequences into file # seqout ($file, $string)
sub seqout {
	my $file = shift;
	my $string = shift;
	print STDERR "[INFO]\topen $file for writing extrated random protein sequence..\n";
	open (OUT, ">$file") || die($!); # open file for reading
	print OUT $string; # write string into file
	close OUT;
}
1;
