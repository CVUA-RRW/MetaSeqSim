#!/usr/bin/env bash
#set -e
#set -u
#set -o pipefail

# Build a BLAST databse containing RefSeq Mitochondrion genomes
# Author: G. Denay, gregoire.denay@cvua-rrw.de

VERSION="1.0"

# Take arguments
USAGE="Usage: $0 -o OUTPUT [$PWD] -f FASTQDIR [$PWD] -p PROFILE_NAME [err_profile] [-h] [-v]"

while getopts :o:f:p:hv opt
do
	case $opt in
	o	)	output=$OPTARG
			;;
	f	)	fastqdir=$OPTARG
			;;
	p	)	profile=$OPTARG
			;;
	h	)	help=true
			;;
	v	)	version=true
			;;
	:	) 	echo "Missing option argument for -$OPTARG" >&2
			echo $USAGE >&2
			exit 1
			;;
	\?	)	echo "$0: invalid option -$OPTARG" >&2
			echo $USAGE >&2
			exit 1
			;;
	esac
done

# help
if [[ $help == true ]]
then 
	echo "create_error_profile.sh (version: $VERSION)"
	echo "Create custom error profiles from previous sequencing runs"
    echo "Files must follow Illumina naming convention:"
    echo "  <sample name>_Sx_L00x_Rx_xxx.fastq.gz"
	echo
	echo $USAGE
	echo
	echo "Options:"
	echo "	-o: output directory for the error profile"
	echo "	-f: path to the sequencing run directory"
	echo " 	-p: clean-up source files before exiting"
	echo "	-v: Print version and exit"
	echo "	-h: Print this help and exit"
fi	

# version
if [[ $version == true ]]
then 
    echo $VERSION
fi

# if no directory specified use current directory
if [ -z "$output" ]
then 
	output="$PWD"
fi

if [ -z "$fastqdir" ]
then 
	fastqdir="$PWD"
fi

if [ -z "$profile" ]
then 
	profile="err_profile"
fi

# Create Output directory
if [ ! -d "$output" ] 
then 
	mkdir -p "$output"
fi

cd "$output"
mkdir temp

# Rename files and transfer them in temp folder
for file in $(ls ${fastqdir}*_R1_*.fastq.gz); do
    newname=$(echo ${file##*/} | sed -e 's;\(.*\)\.fastq\.gz;temp\/\1\.1\.fq\.gz;')
    cp -a  $file $newname
done

for file in $(ls ${fastqdir}*_R2_*.fastq.gz); do
    newname=$(echo ${file##*/} | sed -e 's;\(.*\)\.fastq\.gz;temp\/\1\.2\.fq\.gz;')
    cp -a  $file $newname
done

# run art 
art_profiler_illumina ${profile} temp fq.gz

# clean temp folder
rm -r temp
