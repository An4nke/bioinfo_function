# package define
package CM::gncttr_global;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw($genom $seq $minsize $tmp $model $header $limit %starts %stops $score $name);


## variables
# parameter
our $genom = "";
our $seq = 0;
our $minsize = 100; # minsize of genes
our $tmp = "/tmp";
our $model = "";
our $header = "";
our $limit = 100000;
our $score = 50;
our $name = "";

# data
#our @starts = ('ATG', 'TTG', 'CTG', 'GTG');
our %starts = (
	'ATG' => 1,
	'TTG' => 1,
	'CTG' => 1,
	'GTG' => 1
);
#our @stops = ('TAA', 'TAG', 'TGA');
our %stops = (
	'TAA' => 1,
	'TAG' => 1,
	'TGA' => 1
);
1;
