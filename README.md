# MetaSeqSim - Metabarcoding sequencing simulator

This pipeline simulates metabarcoding sequencing runs (paired-end) according to a user provided sample composition
and reference sequence database.

## Getting started

### Prerequisites 

MetaSeqSim runs in a UNIX environment with BASH (tested on Debian GNU/Linux 10 
(buster)) and requires conda and an internet connection (at least for the first run).

### Installing

Start by getting a copy of this repository on your system, either by downloading and unpacking the archive, 
or using 'git clone':

```bash
cd path/to/repo/
git clone https://github.com/CVUA-RRW/MetaSeqSim
```

Set up a conda environment containing snakemake, python and the pandas library and activate it:

```bash
conda create --name snakemake -c bioconda -c anaconda snakemake pandas
conda activate snakemake
```

### Sequence database

To run the pipeline you will need to provide a BLAST-formated reference sequence database.
If you already have a fasta file with your sequences follow the [BLAST documentation](https://www.ncbi.nlm.nih.gov/books/NBK279688/)
to know how to format it.

If you want to extract barcodes from a database of reference genomes you can check out 
our [RRW-PrimerBLAST](https://github.com/CVUA-RRW/RRW-PrimerBLAST) pipeline.

You will also need to provide the [taxdb](https://ftp.ncbi.nlm.nih.gov/blast/db/taxdb.tar.gz) 
files available from the NCBI server.

### Running MetaSeqSim

MetaSeqSim should be run using the snakemake command-line application.
For this you will need to manually fill the config.yaml file with the paths to the required files.
You can also modify the parameters already present in the file.

Then run the pipeline with:

```bash 
snakemake -s /path/to/MetaSeqSim/Snakefile --configfile path/to/config.yaml --use-conda --conda-prefix path/to/your/conda/envs
```

Consult [snakemake's documentation](https://snakemake.readthedocs.io/en/stable/) for more details.

### Sample composition

You can enter the sample composition in a tabular file, as shown below.
Enter one line per species, repeating the sample name to combine species in the same sample.
Species are to be provided with their **taxonomic node number** according to the NCBI's 
taxonomic classififcation.

Note the the read count values affects both reads: a value of 10000 will generate 10000 R1 reads and 10000 R2 reads.

| Sample  | taxid | read_count |
| ------- | ----- | ---------- |
| sample1 | 9913  | 250000     |
| sample1 | 9903  | 100000     |
| sample1 | 9906  | 200        |
| sample2 | 9906  | 500000     |
| sample2 | 9923  | 500        |

**Be sure to use tabulations as field separator and to respect column naming!**

### Configuration file

The configuration file contains the following parameters:

```
# Fill in the path belows with your own specifications:
workdir:                    # Path to output directory
blast_db:                   # Path to BLAST-formated database
taxdb:                      # Path to the folder containing the taxdb files
samples:                    # Path to the sample definition table

# Modify the parameters below:
read_length: 150            # Sequencing read length
mean_fragment_size: 151     # Mean DNA fragment size. Must be > than read_length
quality_shift_R2: -2        # Quality shift of read 2
fragment_size_sdev: 0       # Standard deviation of fragment size
seq_system: MSv3            # Sequencing system
```

If the reference sequence is shorter than the provided read_length and mean_fragment_length, these will be
reduced to math the sequence size, resulting in a full fragment sequencing read.

Accepted values for seq_system are : 

```
  GA1 - GenomeAnalyzer I (36bp,44bp), GA2 - GenomeAnalyzer II (50bp, 75bp)
  HS10 - HiSeq 1000 (100bp),          HS20 - HiSeq 2000 (100bp),      HS25 - HiSeq 2500 (125bp, 150bp)
  HSXn - HiSeqX PCR free (150bp),     HSXt - HiSeqX TruSeq (150bp),   MinS - MiniSeq TruSeq (50bp)
  MSv1 - MiSeq v1 (250bp),            MSv3 - MiSeq v3 (250bp),        NS50 - NextSeq500 v2 (75bp)
```

### Output

The Pipeline will produce two files per samples, following the illumina naming convention:

* <sample_name>_S1_L001_R1_001.fastq.gz
* <sample_name>_S1_L001_R2_001.fastq.gz

The refenrece sequences that were used to genrate these files will also be outputed 
in individual fasta files for inspection.

## Credits

MetaSeqSim is built with [Snakemake](https://snakemake.readthedocs.io/en/stable/) and uses:
* [BLAST+](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download) 
* [ART](https://www.niehs.nih.gov/research/resources/software/biostatistics/art/index.cfm)

## Contributing

For new features or to report bugs please submit issues directly on the online repository.

## License

This project is licensed under a BSD 3-Clauses License, see the LICENSE file for details.

## Author

For questions about the pipeline, problems, suggestions or requests, feel free to contact:

Grégoire Denay, Chemisches- und Veterinär-Untersuchungsamt Rhein-Ruhr-Wupper 

<gregoire.denay@cvua-rrw.de>