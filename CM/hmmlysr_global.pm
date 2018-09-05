# package define
package CM::hmmlysr_global;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw($in $out $score $evalue $filter @scores @evalues);


## Variables
# parameters
our $in = `pwd`; # get current working directory for input
chomp $in;
our $out = "hmmlysr";
our $score = 0;
our $evalue = 1;
our $filter = '.*';

# others
our @scores;
our @evalues;

1;
