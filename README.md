### Goal

Retrieve metadata entries (not download) of sequencing samples.

### Input

A list of accession numbers for NCBI BioProject entries must be provided
The scripts in `./scripts` folder

Optional: `instrument_lookup.tsv` for classifying genomic entries based on the read length (short/long)

Example input creation:

```
echo -e "PRJNA557253\nPRJCA008297" > study_accession_list.txt
```

### Execution

First clone

```
git clone https://github.com/jamonterotena/Sequence-Database-Creator.git
cd Sequence-Database-Creator
```

Then run

```
bash ./scripts/pipeline.sh
```

### Output

A table with the following columns:

##### ENA/GSA-shared columns

run_accession	CRR1296324

run_alias	LA0716_pacbio

study_accession	PRJCA030093

experiment_accession	CRX1190696

experiment_title	LA0716_pacbio

sample_accession	SAMC4131976

instrument_platform	Pacbio Sequel II

library_name	

library_strategy	WGS

library_source	GENOMIC

library_selection	RANDOM

library_layout	SINGLE

scientific_name	Solanum pennellii

source	ENA/GSA

##### ENA-specific columns

secondary_study_accession	SRP216764

secondary_sample_accession	SRS5450110

experiment_accession	SRX6919146

submission_accession	SRA969619

tax_id	4081

library_name	7

nominal_length	

library_layout	SINGLE

read_count	9951484

base_count	78886408764

center_name	SUB6357167

first_public	05-05-20

last_updated	05-05-20

experiment_title	PromethION sequencing: Whole genome sequencing of Solanum lycopersicum : mature leaf

study_title	The Structural Variant Landscape of Tomato

study_alias	PRJNA557253

experiment_alias	7

run_alias	Manalucie.ont.fastq.gz

fastq_bytes	71851186805

fastq_md5	903add2ca12ea3b7905fac6646be1767

fastq_ftp	ftp.sra.ebi.ac.uk/vol1/fastq/SRR101/002/SRR10199002/SRR10199002_1.fastq.gz

fastq_aspera	fasp.sra.ebi.ac.uk:/vol1/fastq/SRR101/002/SRR10199002/SRR10199002_1.fastq.gz

fastq_galaxy	ftp.sra.ebi.ac.uk/vol1/fastq/SRR101/002/SRR10199002/SRR10199002_1.fastq.gz

submitted_bytes	

submitted_md5	

submitted_ftp	

submitted_aspera	

submitted_galaxy	

submitted_format	

sra_bytes	61330830022

sra_md5	a43924d10839c7543d8c15dc2d4ba2af

sra_ftp	ftp.sra.ebi.ac.uk/vol1/srr/SRR101/002/SRR10199002

sra_aspera	fasp.sra.ebi.ac.uk:/vol1/srr/SRR101/002/SRR10199002

sra_galaxy	ftp.sra.ebi.ac.uk/vol1/srr/SRR101/002/SRR10199002

sample_alias	Manalucie

broker_name	

sample_title	Plant sample from Solanum lycopersicum

nominal_sdev	

first_created	05-05-20

bam_ftp	

bam_bytes	

bam_md5	

fastq_file_role	GENERATED_FILE

submitted_file_role	

sra_file_role	ARCHIVAL_FILE

bam_file_role	

##### GSA-specific columns

run_data_file_type	fastq

read_filename_1	CRR1296324.fastq.gz (47457161276 bytes)

read_file1_md5	2d01eb9c20e45afd7163a3939983227d

download_read_file1	ftp://download.big.ac.cn/gsa5/CRA018974/CRR1296324/CRR1296324.fastq.gz

read_filename_2	

read_file2_md5	

download__read_file2	

index_filename_1	

index_file1_md5	

download_index_file1	

index_filename_2	

index_file2_md5	

download_index_file2	

reference_file_name	

md5_for_reference_file	

assembly_name_or_accession	

assembly_accession_url	

other_db	

accession_in_other_db	

other_db_url	

biosample_name	LA0716_pacbio

library_construction_/_experimental_design	DNA-seq S.pennellii were sequenced on Pacbio sequel II platform. Genomic DNA was extracted from fresh leaves for each accession and SMRTbell library was constructed for sequencing according to PacBios standard protocol (Pacific Biosciences, CA, USA).

read_length_for_mate1(bp)	

read_length_for_mate_2(bp)	

insert_size_(bp)	

nominal_size_(bp)	

nominal_standard_deviation_(bp)	

planned_number_of_cycles	

sample_name	LA0716_pacbio

public_description	Pacbio HiFi of LA0716

project_accession	PRJCA030093

sample_title	LA0716_pacbio

cultivar	wild

biomaterial_provider	Institute of Advanced Agricultural Sciences

tissue	Leaf

age	

age_unit	

dev_stage	seeding

cell_line	

cell_type	

collected_by	

collection_date	

culture_collection	

disease	

disease_stage	

genotype	

growth_protocol	

height_length	

isolation_source	

latitude_longitude	

phenotype	

population	

type	

sex	

specimen_voucher	

temperature	

treatment	

##### publication details

pmc_code

publication_title

publication_url

##### Type of reads

read_length	short/long depending on instrument_platform

##### TGRC-specific columns (only for tomato)

tgrc_code	LA0103

tgrc_available	Yes

tgrc_url	https://tgrc-mvc.plantsciences.ucdavis.edu/Accession/detail/LA0103

tgrc_status	tgrc_shipment_possible

collection_number

tgrc_status	Active

tgrc_shipment_possible	Yes

collection_number	

##### CGN-specific columns (only for tomato)

cgn_code

cgn_available

cgn_url

cgn_smta_needed
