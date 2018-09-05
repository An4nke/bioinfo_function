# package define
package CM::blastanaut_global;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw($options $help $input $readir $datadir $blast $evalue_limit $bitscore_limit $name $kingdom $stat_all $stat_hit $stat_filtered $blasta $word %organisms %filehandles @indices $max);


## variables
# for parameters
our $options = "";
our $help = "";
our $input = "";
our $readir = "";
our $datadir = "";
our $blast = 0; # type of BLAST reslut for analysis: 0 -> BLASTp (default), 1 -> tBLASTn
our $evalue_limit = 1; # evalue trashold for result output
our $bitscore_limit = 0; # bitscore trashold for result output
our $name = "blastanaut_";
our $kingdom = "";
our $max = 1000;

# statistics
our $stat_all = 0; # number of blast results files
our $stat_hit = 0; # number of blast hits
our $stat_filtered = 0; # number of blast results after evalue/bitscore filtering
our $stat_whiped = 0; # number of removed blast files

# others
our $blasta = "BLASTp";
our $word = "protein";
our @dir; # read in directory of BLAST results
our %organisms; # hash for counting organisms
our %filehandles; # hash for filehandle
our @indices; # array with array indices for removal of files

1;
