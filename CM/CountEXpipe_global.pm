# package define
package CM::CountEXpipe_global;

use strict;
use warnings;

## export globals 
use Exporter qw(import);
our @EXPORT_OK = qw($strand $anfile $input $norm $workdir $files %desc %genom %exp @spikin @tex @virus @control @small @mRNA @control @exeptions %keys %coords $genome %count $evalue $minsize $threads);


## variables
# parameters
our $strand ='[+-]';
our $anfile = "";
our $input = "";
our $norm = 0; # 0 -> print out RAW numbers; 1 -> normalization counts by number of all reads
our $evalue = 0.0001;
our $minsize = 16;
our $threads = 8;
our $workdir = "/net/elara/scratch/clara/Doktorarbeit/EBOV/Ebola_2017";

# data
our $genome; # hashref of gene names
our %count; # hash for counting data # genename => file => number
our $files;
our %desc; # remembering TRIMMED/MAPPED
our %exp; # mock => "mock*sam" => ["small", "total"]; virus => "EBOV" => "EBOV*sam" => ["small", "total"]

# filtering
our @virus = ('1439', '1_S2', '1B', 'A2_S3', '1A_S6', 'EBOV', 'wtRNA'); #
our @control = ('Mock', '4B_S2', '4B_S11', '2_S8', '-L');
our @small = ('small', 'micro', 'sRNA', 'miRNA', '2_S8', 'sRNA_S2');
our @mRNA = ('total', 'mRNA', 'poly', 'totRNA', 'sRNA_S1', '1_S7');
our @spikin = ('4_S8');
our @tex = ('\+TEX', '1B_S4', '1B_S1', 'A_S1', '1-sRNA_S1', '1-sRNA_S2', '4B_S2'); # wront annotations!!
our @exeptions = ('Ebola', 'uncharacterized_LOC', 'small_nucleolar_RNA', 'chromosom_\d_open_reading_frame');
our %genom = (
	'Nhe' => 'NHE',
	'MG' => 'MG',
	'd5spacer' => 'DELTA'
);
our %keys = (
	"Nhe" => "NheI_mini",
	"MG" => "MG_mini",
	"Delta5" => "Delta_mini",
	"Ebolagenome" => "Ebola",
);
our %coords = (
	"NheI_mini" => [3047, 3101, 3102, 4535, 4536, 5210],
	"MG_mini" => [3047, 3101, 3102, 4535, 4536, 5210],
	"Delta_mini" => [3047, 3101, 3102, 4522, 4523, 5199],
	"Ebola" => [1, 55, 56, 3026, 18283, 18959]
);
our %mapping = (
	"Nhe" => "/net/elara/scratch/clara/Doktorarbeit/EBOV/mapto/Minigenome_Nhe1.fasta",
	"MG" => "/net/elara/scratch/clara/Doktorarbeit/EBOV/mapto/Minigenome_MG.fasta",
	"d5spacer" => "/net/elara/scratch/clara/Doktorarbeit/EBOV/mapto/Minigenome_Delta5.fasta",
	"Ebolagenome" => "/net/elara/scratch/clara/Doktorarbeit/EBOV/mapto/Ebolagenome_MG_NC_002549.fasta"
);

#our @mini = ('MG', 'Nhe');
#our $gtf = '/net/elara/scratch/clara/Doktorarbeit/EBOV/mapto/Ebola_virus_MG.gtf';


		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		

