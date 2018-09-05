# package define
package CM::FASTA;


use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(align mot);


# create alignment from certain set of sequences # align ($NT1set, $C1dir, $file)
sub align {
	my $arr = shift;
	my $dir = shift; # directory of files
	my $out = shift;
	unless (-s "$dir/$out.fasta") {
		print STDERR "[INFO]\tcreating fasta of sequence files..\n";
		foreach (@$arr) { # CCA sequence filehandle
			if ("$dir/$_" eq "$dir/$out.fasta") { next; }
			my $cmd = "cat $dir/$_ >>$dir/$out.fasta";
			print STDERR "$cmd\n";
			system $cmd;
		}
	}
	# align sequences
	unless (-s "$dir/$out.aln") {
		my $oul = "clustalo --threads 8 --infile $dir/$out.fasta >$dir/$out.aln";
		print STDERR "[INFO]\tcalculating alignment..\n";
		print STDERR "[INFO]\t$oul\n";
		system $oul;
	}
}

# remove certain sides of alignment -> functional??? # $mod_align = mot ($aln, $dir, $motive)
sub mot {
	my $aln = shift;
	my $dir = shift;
	my $motive = shift;
	if ($motive == 1) {
		my $cmd = "perl /home/clara/Projekte/CCApredictor/catal.pl $dir/$aln.aln >$dir/$aln.noLOOP.aln";
		print STDERR "$cmd\n";
		system $cmd;
		return ("$aln.noLOOP");
	} else { return ("$aln"); }
}

1;
