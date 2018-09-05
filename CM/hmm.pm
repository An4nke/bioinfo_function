# package define
package CM::hmm;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(nofltest test compare hmmbuild hmms nhmmr hprot hsearch testing cross_validation);

# include module global
use lib '/home/clara/Projekte/CMPERL/'; # search for moduls into cwd
use CM::arr qw(break_down);
use CM::file qw(cleanup);
use CM::FASTA qw(align);
use CM::statistic qw(mean);


# testing hmm of cds # test ($cds, $tmp_file, $model)
sub test {
	my $tmp = shift;
	my $input = shift;
	my $mod = shift;
	seqout ($tmp, $input); # save cds into tmp file
	my $cmd = "hmmsearch --cpu 8 --noali $mod $tmp";
	print STDERR "$cmd\n";
	my @tmp = split (/\n/, qx{$cmd}); # do hmmsearch, save and split output
	my @good = (grep (/^\s+\d+/, @tmp)); # extract lines containing results
	if ($good[0]) {
		print "$good[0]\n";
		# save seq
	}
	unlink $tmp; # remove tmp file
}

# testing hmm without writing cds into file? # nofltest ($cds, $model)
sub nofltest {
	my $string = shift;
	my $mod = shift;
	unless ($mod) { die("[ERROR]\tno HMM for testing!\n"); }
	my $cmd = "echo \"$string\" | hmmsearch --cpu 8 --noali $mod -"; # use hmmsearch from stdin
	print STDERR "$cmd\n";
	my @tmp = split (/\n/, qx{$cmd}); # do hmmsearch, save and split output
	my @good = (grep (/^\s+\d+/, @tmp)); # extract lines containing results
	if ($good[0]) {
		print STDERR "[HIT]\t$good[0]\n";
		my @line = split (/\s+/, $good[0]);
		return \@line;
	} else { return 0; }
}

# comparing hmm results
sub compare {
	my $result = shift;
	my @values = sort {$b <=> $a} values %$result;
	my @keys = sort {$$result{$b} <=> $$result{$a}} keys %$result;
	for (my $i = 0; $i < scalar @values; $i++) {
		if ($values[$i] == $values[$i+1]) {
			#print "$values[$i] == $values[$i+1]\n";
			print STDERR "[INFO]\tmultiple highest score: $values[$i]\n";
			print "$keys[$i]\n$keys[$i+1]\n";
		} else {
			#print "$values[$i] > $values[$i+1]\n";
			print STDERR "[INFO]\thighest score: $values[$i]\n";
			print "$keys[$i]\n";
			last;
		}
	}
}

# build hmm model (hmmbuild) # hmmbuild ("$dir/$name");
sub hmmbuild {
	unless (-e "$_[0].hmm") { # model already existence?
		my $build = "hmmbuild --cpu 8 $_[0].hmm $_[0].aln >/dev/null";
		print STDERR "[INFO]\tbuilding hmmer model ..\n$build\n";
		system $build;
	}
}

# hmmsearch inside set of sequences # my ($hit, $loose) = hsearch (\@set, $aln, $dir, $evalue, $score) # more detailed output
sub hsearch {
	my $et = shift;
	my $aln = shift;
	my $dir = shift;
	my $evalue = shift;
	my $score = shift;
	my $hit = 0; my $loose = 0;
	foreach (@$et) {
		my $cmd = "hmmsearch --cpu 8 --noali $aln.hmm \"$dir/$_\"";
		print STDERR "$cmd\n";
		my @tmp = split (/\n/, qx{$cmd}); # do hmmsearch, save and split output
		my @good = (grep (/^\s+\d+/, @tmp)); # extract lines containing results
		if ($good[0]) {
			my @e = split (/\s+/, $good[0]); # extract evalue
			#print STDERR "[EVALUE]\t$e[1]\n";
			#print STDERR "[HIT]$good[0]\n";
			if ($e[1] <= $evalue && $e[2] >= $score) { # test evalue
				$hit++;
				print STDERR "[HIT]$good[0]\n";
				#print "$e[2]\n";
				# print better output!
			} else { $loose++; } # remember lousy hit 
		} else { $loose++; } # no hit detected
	
	}
	#print "$hit\t$loose\n";
	return ($hit, $loose);
}

# testing AA HMM against protein database -> get query name of hits # my $result_hash = hprot ($aln, $query)
sub hprot {
	my $aln = shift;
	my $query = shift;
	my %hit;
	my $head = 0;
	my $cmd = "hmmsearch --cpu 8 --noali $aln \"$query\"";
	print STDERR "$cmd\n";
	my @tmp = split (/\n/, qx{$cmd}); # split into lines
	foreach (@tmp) { 
		if ($_ =~/^>>\s([^\s]+)\s/) { # get header -> file of hits # >> tr|A0A1W2CPJ1|A0A1W2CPJ1_9FIRM  tRNA nucleotidyltransferase/poly(A) polymerase OS=Sporomusa malonica OX=112901 GN=SAM
			$head = $1;
		}
		if ($_ =~/^\s+\d+/) {	#    1 !  372.8   5.4  3.8e-114  1.2e-111     510     891 ..       6     467 ..       1     472 [. 0.93
			my @e = split (/\s+/, $_); # split line containing results
			push @{ $hit{$head} }, @e;
		}
	}
	if ($head) {
		return \%hit;
	} else { return 0; }
}

 

# test model against sequence # my $results = hmms ($aln, $query)
sub hmms {
	my $aln = shift;
	my $query = shift;
	my $cmd = "hmmsearch --cpu 8 --noali $aln \"$query\"";
	my @e;
	print STDERR "$cmd\n";
	my @tmp = split (/\n/, qx{$cmd}); # do hmmsearch, save and split output
	my @good = (grep (/^\s+\d+/, @tmp)); # extract lines containing results
	if ($good[0]) {
		@e = split (/\s+/, $good[0]); # extract evalue
		shift @e; # remove first element
	} else { push @e, '0'; } # no hit detected	
	return \@e;
}

# search with model inside DNA database/genome
sub nhmmr {
	my $model = shift;
	my $genome = shift;
	my @stats;
	my $cmd = "nhmmer --cpu 8 --noali $model \"$genome\""; # do nhmmer -> search with model inside nucleotide database
	print STDERR "$cmd\n";
	my @tmp = split (/\n/, qx{$cmd}); # extraction of nhmmer output
	my @good = (grep (/^\s+\d+/, @tmp)); # extract lines containing results
	if ($good[0]) { # check!
		@stats = split (/\s+|\t+/, $good[0]);
		#print "$stats[1]\t$stats[4]\t$stats[5]\t$stats[6]\n"; # e-value?	chromosom?	start?	end?
		print STDERR "[INFO]\thit found in $genome!\n[STAT]\t$stats[1]\t$stats[4]\t$stats[5]\t$stats[6]\t$stats[7]\t$stats[8]\n";
		return \@stats;
	} else { print STDERR "[INFO]\tNo hit found in $genome!\n"; return \@stats;}
	
}


## rebuild!
# split dataset $rep x in 1/2 -> create alignment + hmmer model -> test 1/2 rest sequences # cross_validation ("CCAI_nt", $dir, \@data, $prefix, $rep, $evalue, $score) 
sub cross_validation {
	my $name = shift; # name of testing set
	my $dir = shift; # directory containing sequences for testing
	my $arr = shift; # array of fasta sequences filehandles
	my $prefix = shift; # prefix of files
	my $rep = shift; # number of repetitions
	my $evalue = shift; # evalue threshold
	my $score = shift; # score threshold
	my $random = $name."--".@$arr[int(rand(scalar @$arr))];
	$random =~s/\.$prefix$//;
	my @bad; # all negative results
	my @good; # all positive results
	print STDERR "[INFO]\tCross-Validation of model for sequences from $dir..\n";
	print "#$name\n#good\tbad\n"; # print out result header
	for (my $x = 1; $x <= $rep; $x++) {
		my ($set, $tmp) = break_down ($arr); # open directory containing CCA adding enzymes
		cleanup ("$dir/$random", "fasta"); # clear FASTA for alignment
		align ($set, $dir, $random); # build alignments with 1/2 n sequences
		#$random = mot ($random, $dir); # cut out flexible loop between Motiv A & Motiv B if wanted
		hmmbuild ("$dir/$random"); # build hmm model (hmmbuild)
		my ($hit, $loose) = hsearch ($tmp, "$dir/$random", $dir, $evalue, $score);
		print "$hit\t$loose\n";
		push @bad, $loose;
		push @good, $hit;
	}
	print "[MEAN]\t".mean(\@good)."\t".mean(\@bad)."\n"; # print mean of results
	# cleanup
	print STDERR "[INFO]\tremoving processing files\n[INFO]\n$dir/$name.fasta\n[INFO]\n$dir/$name.hmm\n[INFO]\t$dir/$name.aln\n";
	unlink "$dir/$random.fasta";
	unlink "$dir/$random.hmm";
	unlink "$dir/$random.aln";
}

# testing data vs model # testing ($name, $dir, $qdir, \@data, \@query, $rep)
sub testing {
	my $name = shift; # name of query
	my $ddir = shift; # directory containing sequences for model creation
	my $qdir = shift; # directory containing query sequences
	my $data = shift; # array of data filehandle
	my $query = shift; # array of query filehandle
	my $rep = shift; # number of repetiions
	my $random = $name."--".@$data[int(rand(scalar @$data))];
	my @bad; # all negative results
	my @good; # all positive results
	print STDERR "[INFO]\ttesting model from $ddir to query sequences from $qdir..\n";
	print "#$name\n#good\tbad\n"; # print header
	for (my $x = 1; $x <= $rep; $x++) {
		# merge all sequences of model dataset into
		cleanup ("$ddir/$random", "fasta");
		align ($data, $ddir, $random);
		#$random = mot ($random, $dir); # cut out flexible loop between Motiv A & Motiv B if necessary
		hmmbuild ("$ddir/$random"); # create model
		my ($hit, $loose) = hsearch ($query, "$ddir/$random", $qdir); # test model to query # processing results
		print "$hit\t$loose\n"; # print results
		push @bad, $loose;
		push @good, $hit;		
	}
	# calculate & print mean
	print "[MEAN]\t".mean(\@good)."\t".mean(\@bad)."\n"; # print mean of results
	# cleanup
	print STDERR "[INFO]\tremoving processing files\n[INFO]\n$ddir/$name.fasta\n[INFO]\n$ddir/$name.hmm\n[INFO]\t$ddir/$name.aln\n";
	unlink "$ddir/$random.fasta";
	unlink "$ddir/$random.hmm";
	unlink "$ddir/$random.aln";	
}

1;
