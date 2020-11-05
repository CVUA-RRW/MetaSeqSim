import pandas as pd

shell.executable("bash")

# Settings ------------------------------------------------------------------------------------------------------------------
 
workdir: config["workdir"]

ssheet = pd.read_csv(config["samples"], index_col=None, sep = "\t", engine="python", 
                     dtype = {'sample': str, 'taxid': int, 'read_count': 'int'})

# Functions -----------------------------------------------------------------------------------------------------------------

def get_samples():
    return [str(e) for e in ssheet['sample'].unique()]

def get_R1_names(wildcards):
    taxids = ssheet[ssheet["sample"] == wildcards.sample]["taxid"]
    return ["fastq/" + wildcards.sample + "_" + str(txd) + "_R1.fq" for txd in taxids]
     
def get_R2_names(wildcards):
    taxids = ssheet[ssheet["sample"] == wildcards.sample]["taxid"]
    return ["fastq/" + wildcards.sample + "_" + str(txd) + "_R2.fq" for txd in taxids]

def get_count(wildcards):
    sub_df = ssheet[ssheet["sample"] == wildcards.sample]
    return int(sub_df[sub_df["taxid"] == int(wildcards.taxid)]["read_count"])

# Input rule ----------------------------------------------------------------------------------------------------------------
 
rule all:
    input: 
        expand("samples/{sample}_S1_L001_R{N}_001.fastq.gz", sample = get_samples(), N = [1, 2])

# Workflow ------------------------------------------------------------------------------------------------------------------

rule extract_fasta:
    output:
        "fasta/{taxid}.fa"
    params:
        blast_db = config["blast_db"],
        taxdb = config["taxdb"]
    message: "Extracting fasta for taxid {wildcards.taxid}"
    conda: "envs/blast.yaml"
    shell:
        """
        export BLASTDB={params.taxdb}
        blastdbcmd -db {params.blast_db} -taxids {wildcards.taxid} -out {output} \
                   -outfmt '%f'
        
        if [ $(grep -c '^>' {output}) -ne 1 ]; then
            echo "Expected one sequence for taxid {wildcards.taxid}, got $(grep -c '^>' {output})"
            exit 1
        fi
        """

rule generate_reads:
    input:
        "fasta/{taxid}.fa"
    output:
        temp(multiext("fastq/{sample}_{taxid}", "_R1.fq", "_R2.fq"))
    params:
        rcount = get_count,
        length = config["read_length"],
        mflen = config["mean_fragment_size"],
        qshift2 = config["quality_shift_R2"],
        sdev = config["fragment_size_sdev"],
        seqSys = config["seq_system"]
    message: "Generating taxid {wildcards.taxid} reads for samples {wildcards.sample}"
    conda: "envs/art.yaml"
    shell:
        """
        len=$(tail -n+2 {input} | tr -d '[:space:]' | wc -c)
        
        if [ {params.mflen} -gt $len ]; then
            mflen=$len
        else
            mflen={params.mflen}
        fi
        
        if [ {params.length} -gt $len ]; then
            length=$((mflen-1))
        else
            length={params.length}
        fi
        
        art_illumina --amplicon \
                     --rcount {params.rcount} \
                     --in {input} \
                     --len $length \
                     --mflen $mflen \
                     --noALN \
                     --out fastq/{wildcards.sample}_{wildcards.taxid}_R \
                     --paired \
                     --qShift2 {params.qshift2} \
                     --sdev {params.sdev} \
                     --seqSys {params.seqSys}
        """

rule mix_reads:
    input:
        r1 = get_R1_names,
        r2 = get_R2_names
    output:
        r1 = temp("samples/{sample}_S1_L001_R1_001.fastq"),
        r2 = temp("samples/{sample}_S1_L001_R2_001.fastq")
    message: "Combining reads for sample {wildcards.sample}"
    shell:
        """
        cat {input.r1} > {output.r1}
        cat {input.r2} > {output.r2}
        """
        
rule compress:
    input:
        "samples/{sample}_S1_L001_R{N}_001.fastq"
    output:
        "samples/{sample}_S1_L001_R{N}_001.fastq.gz"
    message: "Compressing file {wildcards.sample}_S1_L001_R{wildcards.N}_001.fastq"
    shell:
        """
        gzip -c {input} > {output} 
        """