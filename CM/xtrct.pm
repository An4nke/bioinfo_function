# package define
package CM::xtrct;

use warnings;
use strict;


# include module global
use lib '/home/clara/Projekte/CMPERL/'; # search for moduls into cwd
use CM::rev_comp qw(rev_comp);
use CM::file qw(wrt);


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(check lone_check xtrct_pro xtrct_chr xtrct_ncl exblasta exgen mem extract get_type blasta bla_db);

# count number of mapped reads in MEHL format mapping file
sub check { # my $cnt = check ("key", "*.mehl", "start", "ende")
	my %hash;
	my $cnt = 0;
	my $cmd = "grep $_[0] $_[1]"; # counting virus genome
	#print STDERR "[XTRCT]\t$cmd\n";
	foreach (qx($cmd)) {
		if ($_=~ /^#/) { next; } # skip header
		my @row = split(/\t/);
		my $read = $row[1];
		my $strand = $row[9];
		if ($strand ne "+") { next; } # skipping antisense mapping
		if (defined($hash{$read})) { next; } # skip already counted reads
		$hash{$read} = 1;
		if ($_[2] && ($row[10] >= $_[2]) && ($row[10] < $_[3]) && ($row[11] <= $_[3]) && ($row[11] > $_[2])) { # $row[10] -> start of mapped read, $row[11] -> end of mapped read
			#print "$row[10] >= $_[2] && $row[10] < $_[3] && $row[11] <= $_[3] && $row[11] > $_[2]\n";
			$hash{$read} = 1;
			$cnt++;
		} elsif (!$_[2]) { $cnt++; }
	}
	return $cnt;
}

# only count number of reads mapped to certain genome
sub lone_check { # my $cnt = lone_check ("*.mehl")
	my %hash;
	my $cnt = 0;
	open (my $MEHL, "<$_[0]") || die ($!);
	while (<$MEHL>) {
		if ($_=~ /^#/) { next; } # skip header
		my @row = split(/\t/);
		my $read = $row[1];
		my $strand = $row[9];
		if ($strand ne "+") { next; } # skipping antisense mapping
		if (defined($hash{$read})) { next; } # skip already counted reads
		$hash{$read} = 1;
		$cnt++;
	}
	return $cnt;
}


# extraction of sequences by coordinates # extract ($chrom, $start, $end, $genom_file, $output_file, $name)
sub extract {
	my $chr = shift;
	my $start = shift;
	my $end = shift;
	my $genom = shift;
	my $out = shift;
	my $name = shift;
	unless (-e "$out/$name.fasta") { # only extract protein if fasta is nonexisting
		my $cmd = "perl /home/clara/Projekte/CCApredictor/gex.pl --start=$start --end=$end --name=$name --chromosome=$chr --genome=$genom >$out/$name.fasta"; # perl /home/clara/Projekte/CCApredictor/gex.pl --start=4077322 --end=4077592 --name=Methanosarcina_barkeri_str__Fusaro__strain_Fusaro --genome=/net/elara/scratch/clara/Doktorarbeit/CCA/CCApredictor/GENOMES/archaea/Methanosarcina_barkeri_str__Fusaro__strain_Fusaro/GCF_000195895.1_ASM19589v1_genomic.fna >test.fasta
		print STDERR "[INFO]\textraction of $name $start - $end from $genom\n";
		print STDERR "$cmd\n";
		system ($cmd);
	}
}


## find type of RNA in experiment
sub get_type {
	my $test = $_[0];
	my $carr = $_[1];
	my $result = $_[2];
	my $type = 0;
	if (grep ($test =~/$_/i, @$carr)) {
		$type = $result;
	}
	return $result;
} 


## preparation of gene names from human transcripts # my ($ID, $name) = mem $header
sub mem {
	if ($_[0] =~m/^>([^\s]+)\s(.+)/) {
		my $ID = $1;
		my $name = $2;

		# short transcription
		$name =~s/.*Homo sapiens (.+)/$1/;
		if ($_ =~m/description:([^:[]+)/) {
			$name = $1;
				$name =~s/,? pseudogene//;
		} else { 
			$name =~s/^.*gene_biotype:([^:]+):.*gene_symbol:(.+)/$1 $2/;
		}
		$name =~s/ $//;
		$name =~s/, transcript variant.*//;
		$name =~s/^RNA //;
		$name =~s/.*U1 small nuclear.*/U1 small nuclear RNA/; # put "U1 small nuclear RNA" together
		$name =~s/,/_/g; $name =~s/\s/_/g;
		return ($ID, $name);
	}
}

# read mapped genome # my $gene_hash = exgen $genom_path
sub exgen {
	my $genom = shift;
	my %hash; # hash containing gene information
	if ($genom) {
		open (my $GENOM, "<$genom") || die($!);
		while (<$GENOM>) {
			chomp;
			if ($_ =~/^>/) {
				my ($ID, $name) = mem $_; # get describition from mapped genome file
				$hash{$ID} = $name;
			}
		}
		close $GENOM;
	}
	return \%hash;
}


# extract protein sequence from faa file # my ($prot_name, $sequence) = xtrct_pro ($faa_file, $subject)
sub xtrct_pro {
	my $faa_file = $_[0]; #path of AA Sequence data file
	my $subject = $_[1]; #protein subject ID
	my $button = 0; #"button"
	my $sequence = "";
	my $prot_name = "";
	$subject =~s/\|/\\\|/g;
	open(my $FAA, "<$faa_file") or die print STDERR "[ERROR]\tFailed to open AS file $faa_file for searching for $subject!\n";
	while (<$FAA>) { # Proteinsequenz einlesen
    	if ($button == 0) {# Suchmodus
			if ($_ =~m/^>($subject.*) OS/) {
				$prot_name = $1;
				$button = 1; #working modus
				next;
               }
		} else { #processing mode
			if (/^>/) {
				$button = 0; #searching modus
					next;
			} else {
				$sequence.=$_;
			}
		}
     }
	close $FAA;
	return ($prot_name, $sequence); #return name of extractet protein + sequence
}

# read *.fna #input: my $chromosom = xtrct_chr ($filehandlfna, $chromosom_name);
sub xtrct_chr {
	my $fna_pfad = $_[0]; # file for reading
	my $chromosom = $_[1]; # keyword for searching
	my $seq = ""; # sequence for extraction
	my $button = 0; # "switch" -> off
	open (my $FNA, "<$fna_pfad") || die print STDERR "[ERROR]\tFailed to open nucleotide data file $fna_pfad for extraction of chromosom sequence $chromosom\n$!";
	while (<$FNA>) { # read nucleotidsequence
		#print "$_\n";
		chomp $_;
		if ($button == 0) { # search mode
			if ($_ =~m/^>$chromosom/) {
				$button = 1; # switch to processing
				next;
			}
		} else { # processing
			if (/^>/) {
			$button = 0; # switch off -> search mode
			next;
			} else {
				$seq.=$_;
			}
		}
	}
	close $FNA;
	return $seq; #Rueckgabe extrahierte Sequenz des Chromosomens
}

# extract certain nucleotid sequence by its coordinates # $sequence = xtrct_ncl ($chromosomsequence, $cds1, $cds2, $species)
sub xtrct_ncl {
	my $chromosom = $_[0];
	my $cds1 = $_[1];
	my $cds2 = $_[2];
	my $start = $cds1-1;
	my $length = $cds2-$cds1;
	if ($length > 0) { # extract (+) strand
        my $sequence = substr($chromosom, $start, $length);
		return $sequence;
    } else { # extract (-) strand
			my $length2 = $cds1-$cds2;
			my $sequence = substr($chromosom, $start, $length2);
			$sequence = rev_comp($sequence); # reverse complement
			return $sequence;
	}
}

# creating blast db
sub bla_db {
	unless (-e "$_[0].nsq") {
		my $cmd = "makeblastdb -dbtype nucl -in $_[0]";
		print STDERR "[INFO]\tCreating nucleotide db for $_[0]..\n";
		print STDERR "$cmd\n";
		system $cmd;
	}
}

# do blast # $result =  blast (*fna, *fasta, 0.0001)
sub blasta {
	if (-e "$_[0].nsq") {
		my $cmd = "blastn -db $_[0] -query $_[1] -evalue $_[2] -outfmt 6"; 
		#print "$cmd\n";
		print STDERR "[INFO]\t$cmd\n";
		my $result = qx($cmd);
		return $result;
	} else {
		print STDERR "[ERROR]\tblast db for $_[0] noexisting!!\n";
	}
}


# extraction of protein from blast file # my ($stat_hit, $stat_filtered) = exblasta ($bla, $bitscore_limit, $stat_hit, $stat_filtered, "$datadir/$group/$species/$GCF", $species, $out, \%organism, $max);
sub exblasta {
	my $blafile = shift;
	my $bitlimit = shift;
	my $counthit = shift;
	my $filtered = shift;
	my $data = shift;
	my $species = shift;
	my $out = shift;
	my $organism = shift;
	my $max = shift;
	my $i = 0;
	if ($blafile) {
		open (my $BLA, $blafile) || die("[ERROR]\t$blafile failed to opne\n$!\n");
		while (<$BLA>) {
			my ($query, $subject, $identity, $align_length, $mismatch, $gapopening, $align_start_query, $align_end_query, $align_start_subject, $align_end_subject, $evalue, $bit_score) = split(/\s+/,$_); #extract parameters from BLAST result file
			$query =~s/\//_/;
			if ($bit_score > $bitlimit) { # bitscore filtering, evalue filtering
				$filtered++; # count filterd hit
				print STDERR "[INFO]\tskipping $subject, hit for $query in $blafile\n";
				next;
			}
			my ($prot_name, $sequence) = xtrct_pro ("$data.faa", $subject); # extract proteinsequence
			$prot_name =~s/^[^\s]+//; $prot_name =~s/[\s,\/\/\(\)\+\*\|><]/_/g; $prot_name =~s/^(.{100}).*$/$1/; $subject =~s/[:\^\|\\\/\*\+><]//g;
			$$organism{"$species\___$subject--$prot_name"}++;	
			if ($i >= $max) { print STDERR "[INFO]\tenough sequences extracted ($max)!\n"; return ($counthit, $filtered); }
			if ($$organism{"$species\___$subject--$prot_name"} == 1) {
				print STDERR "[INFO]\textract $subject from $data.faa\n";
				print ">$species\--$prot_name\tquery: $query\tevalue: $evalue\tbitscore: $bit_score\n$sequence";
				wrt ("$out/$species\___$subject--$prot_name--$query.faa", ">$species\--$prot_name\tquery: $query\tevalue: $evalue\tbitscore: $bit_score\n$sequence"); # write into file
				$i++;
			} else { print STDERR "[INFO]\t$species\___$subject--$prot_name already extracted\n"; }
		}
	}
	return ($counthit, $filtered);
}

1; # the end
