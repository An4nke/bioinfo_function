# package define
package CM::stream_global;

use strict;
use warnings;


## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw($options $help $species $gff $number $gene $genom $protein $strand $key $outformat @dir @species_dir %hits $hit %gff %info %fna %faa $button %data);

## variables
# for parameters
our $options = 0; # options for programm
our $genom = "";
our $help = 0; # show help menu if $help == 1
our $species = "";
our $gff = "";
our $number = 5; # number of up/downstream genes (default: 5)
our $gene = "[^;]+"; # gene for extraction
our $protein = "[^;]+"; # protein name for extraction
our $strand = "[\\+\\-]";
our $key ="";
our $outformat = 0; # output format 0 -> nucleotide, 1 -> amino acid


# others
our @dir; # read in data directory
our @species_dir; # read in species directory
our %hits;
our $hit = "";
our %gff; # filehandle gene annotation files
our %fna; # filehandle nucleotid sequence files
our %faa; # filehandle AS sequence files
our $button = 0; # registrate found of species diretory
our %data;
our %info;


1;
