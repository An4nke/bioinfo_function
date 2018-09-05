# package define
package CM::codons;

use strict;
use warnings;

# include module global
use lib '/home/clara/Projekte/CMPERL/'; # search for moduls into cwd
use CM::gncttr_global qw(%starts %stops);


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(finds codon translate);



## NCBI standard AA code
# TTT F Phe      TCT S Ser      TAT Y Tyr      TGT C Cys  
# TTC F Phe      TCC S Ser      TAC Y Tyr      TGC C Cys  
# TTA L Leu      TCA S Ser      TAA * Ter      TGA * Ter  
# TTG L Leu i    TCG S Ser      TAG * Ter      TGG W Trp  

# CTT L Leu      CCT P Pro      CAT H His      CGT R Arg  
# CTC L Leu      CCC P Pro      CAC H His      CGC R Arg  
# CTA L Leu      CCA P Pro      CAA Q Gln      CGA R Arg  
# CTG L Leu i    CCG P Pro      CAG Q Gln      CGG R Arg  

# ATT I Ile      ACT T Thr      AAT N Asn      AGT S Ser  
# ATC I Ile      ACC T Thr      AAC N Asn      AGC S Ser  
# ATA I Ile      ACA T Thr      AAA K Lys      AGA R Arg  
# ATG M Met i    ACG T Thr      AAG K Lys      AGG R Arg  

# GTT V Val      GCT A Ala      GAT D Asp      GGT G Gly  
# GTC V Val      GCC A Ala      GAC D Asp      GGC G Gly  
# GTA V Val      GCA A Ala      GAA E Glu      GGA G Gly  
# GTG V Val      GCG A Ala      GAG E Glu      GGG G Gly 


## NCBI Bacterial, Archaeal and Plant Plastid Code
# TTT F Phe      TCT S Ser      TAT Y Tyr      TGT C Cys  
# TTC F Phe      TCC S Ser      TAC Y Tyr      TGC C Cys  
# TTA L Leu      TCA S Ser      TAA * Ter      TGA * Ter  
# TTG L Leu i    TCG S Ser      TAG * Ter      TGG W Trp  

# CTT L Leu      CCT P Pro      CAT H His      CGT R Arg  
# CTC L Leu      CCC P Pro      CAC H His      CGC R Arg  
# CTA L Leu      CCA P Pro      CAA Q Gln      CGA R Arg  
# CTG L Leu i    CCG P Pro      CAG Q Gln      CGG R Arg  

# ATT I Ile i    ACT T Thr      AAT N Asn      AGT S Ser  
# ATC I Ile i    ACC T Thr      AAC N Asn      AGC S Ser  
# ATA I Ile i    ACA T Thr      AAA K Lys      AGA R Arg  
# ATG M Met i    ACG T Thr      AAG K Lys      AGG R Arg  

# GTT V Val      GCT A Ala      GAT D Asp      GGT G Gly  
# GTC V Val      GCC A Ala      GAC D Asp      GGC G Gly  
# GTA V Val      GCA A Ala      GAA E Glu      GGA G Gly  
# GTG V Val i    GCG A Ala      GAG E Glu      GGG G Gly  

my %code = (
	'TTT' => 'F', # Phe
	'TTC' => 'F', # Phe
	'TTA' => 'L', # Leu
	'TTG' => 'L', # Leu
	'TCT' => 'S', # Ser
	'TCC' => 'S', # Ser
	'TCA' => 'S', # Ser
	'TCG' => 'S', # Ser
	'TAT' => 'Y', # Tyr 
	'TAC' => 'Y', # Tyr 
	'TAA' => '*', # Ter
	'TAG' => '*', # Ter 
	'TGT' => 'C', # Cys
	'TGC' => 'C', # Cys 
	'TGA' => '*', # Ter
	'TGG' => 'W', # Trp 
	'CTT' => 'L', # Leu 
	'CTC' => 'L', # Leu
	'CTA' => 'L', # Leu 
	'CTG' => 'L', # Leu
	'CCT' => 'P', # Pro 
	'CCC' => 'P', # Pro
	'CCA' => 'P', # Pro
	'CCG' => 'P', # Pro
	'CAT' => 'H', # His
	'CAC' => 'H', # His
	'CAA' => 'Q', # Gln
	'CAG' => 'Q', # Gln
	'CGT' => 'R', # Arg
 	'CGC' => 'R', # Arg
	'CGA' => 'R', # Arg
	'CGG' => 'R', # Arg
	'ATT' => 'I', # Ile
	'ATC' => 'I', # Ile
	'ATA' => 'I', # Ile
	'ATG' => 'M', # Met
	'ACT' => 'T', # Thr
	'ACC' => 'T', # Thr
	'ACA' => 'T', # Thr
	'ACG' => 'T', # Thr
	'AAT' => 'N', # Asn
	'AAC' => 'N', # Asn
	'AAA' => 'K', # Lys
	'AAG' => 'K', # Lys
	'AGT' => 'S', # Ser
	'AGC' => 'S', # Ser
	'AGA' => 'R', # Arg
	'AGG' => 'R', # Arg
	'GTT' => 'V', # Val
	'GTC' => 'V', # Val
	'GTA' => 'V', # Val
	'GTG' => 'V', # Val
	'GCT' => 'A', # Ala
	'GCC' => 'A', # Ala
	'GCA' => 'A', # Ala
	'GCG' => 'A', # Ala
	'GAT' => 'D', # Asp
	'GAC' => 'D', # Asp
	'GAA' => 'E', # Glu
	'GAG' => 'E', # Glu
	'GGT' => 'G', # Gly
	'GGC' => 'G', # Gly
	'GGA' => 'G', # Gly
	'GGG' => 'G', # Gly
);


# find stopcodons -> find startcodons
sub finds {
	my $hash = shift;
	my %end;
	my %begin;
	foreach (keys %$hash) {
		if (exists $stops{$$hash{$_}}) { # search for stopcodon 
			$end{$_}++;
		}
		if (exists $starts{$$hash{$_}}) { # search for startcodons 
			$begin{$_}++;
		}
	}
	return (\%begin, \%end);
}

# split string into codon # $codons = codon $seq
sub codon {
	my $seq = shift;
	my %pos;
	for (my $i = 0; ((length $seq) - $i) >= 3; $i+=3) {
		my $codon = substr($seq, $i, 3); # split into codons
		if ($codon =~/[ATCGN]{3}/) {
			$pos{$i} = $codon;
		}
	}
	return \%pos;
}

# translate codons into AA sequence # fasta header!
sub translate {
	my $seq = shift;
	my $AA = "";
	$seq =~s/[\n\s\t]//g;
	if ($seq =~/[^ATCGN]/) { print STDERR $1."\n[ERROR]\tmalformed codon sequence!\n"; return 0; }
	my $codons = codon $seq; # split sequence into triplets
	foreach (sort {$a <=> $b} keys %$codons) { # sort codons by position
		if ($$codons{$_} =~/[ACTG]{3}/) {
			$AA .= $code{$$codons{$_}}; # translate
		} elsif ($$codons{$_} =~/N/) {
			$AA .= 'X';
		}
	}
	return $AA;
}



1; # very, very, very important! sonst not importing!!
