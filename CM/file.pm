# package define
package CM::file;

use warnings;
use strict;

# include module global
use lib '/home/clara/Projekte/CMPERL/'; # search for moduls into cwd

## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw(readvz cleanvz ffile wrt wrta cleanup);

# read directory # @indir = readvz($dir)
sub readvz {
	opendir (RI, $_[0]) || die ($!); # open directory
	my @vz = grep {!/^\.\.?$/} readdir RI; # do not read . and ..
	closedir RI;
	return @vz;
}

# read in directory & clean up empty files # my ($indices, $whiped) = cleanvz ($dir);
sub cleanvz {
	my $dir = shift;
	my @indices;
	my $i = 0;
	my $whiped = 0;
	print "$dir\n";
	opendir (my $DIR, $dir) || die ($!); 
	my @dir = grep { $_ ne '.' && $_ ne '..'} readdir $DIR;
	foreach (@dir) {
		if (-z "$dir/$_") {
			my $remove = unlink ("$dir/$_") || die ($!);
			unshift @indices, $i; # save array indices for removal
			print STDERR "[INFO]\t$dir/$_ removed!\n";
			$whiped++;
		}
		$i++;
	}
	closedir $DIR;
	foreach (@indices) { splice(@dir, $_, 1); } # remove empty files
	return \@dir;
}

# find certain files
sub ffile {
	my $search = shift;
	my @files = glob $search;
	return \@files;
}

# clear certain file # cleanup ($name, "fasta")
sub cleanup {
	my $file = shift;
	my $form = shift;
	print STDERR "[INFO]\tcleanup $file.$form\n";
	truncate "$file.$form", 0; # clear file
}


# write text into file # wrt ($outfile, $output)
sub wrt {
	print STDERR "[INFO]\twriting sequence into $_[0]\n";
	if ($_[0]) {
		open (my $OUT, ">$_[0]") || die($!);
		print $OUT $_[1];
		close $OUT;
	}
}

sub wrta {
	my $file = shift;
	my $arr = shift;
	print STDERR "[INFO]\twritting array into $file\n";
	if ($file) {
		open (my $OUT, ">$file") || die($!);
		foreach (@$arr) {
			print $OUT "$_\n";
		}
		close $OUT;
	}
}

1;
