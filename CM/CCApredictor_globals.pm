# package define
package CM::CCApredictor_globals;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw($dir $dir2 $qdir $job $name $prefix $prefix2 $evalue $rep $motive $out $model1 $model2 $mod $mod2 %set @data @data2 @query $all $cca1 $cca2 $none $score);


## Variables
# parameters
our $dir = ""; # directory containing files
our $dir2 = ""; # directory containing second data for model 2
our $qdir = ""; # directory containing query
our $job = 1; # 0 -> create training set; 1 -> test data; 2 -> find & extract unannotated proteins; 3 -> compare 2 differen Protein models
our $name = "test";
our $prefix = 'faa'; # typ for analysis: AA -> faa; NT -> fna
our $prefix2 = 'fasta';
our $evalue = 0.00001;
our $score = 0;
our $rep = 100;
our $motive = 0;
our $out = ""; # output directory for protein extraction
our $model1 = "CCAI"; # name of first Model
our $model2 = "CCAII"; # name of second Model
our $mod = ""; # existing HMM for testing
our $mod2 = ""; # second existing HMM for testing

# data
our %set = ('bacteria' => 'CCAII', 'archaea' => 'CCAI');
our @data; # array containing filehandel for model creation
our @data2; # array containing filehandel for second model creation
our @query; # array containing filehandel for testing

# statistic
our $all = 0;
our $cca1 = 0;
our $cca2 = 0;
our $none = 0;


1;
