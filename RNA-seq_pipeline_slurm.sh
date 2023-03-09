#!/bin/bash
#SBATCH --job-name=RNAseq_pipeline
#SBATCH --partition=PartitionName
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --mail-user= youremail.here@umn.edu  
#SBATCH --mail-type=ALL
#SBATCH --output=RNAseq_pipeline.log
#SBATCH --error=RNAseq_pipeline.log

cd ${SLURM_SUBMIT_DIR}
echo ${SLURM_SUBMIT_DIR}
echo "$SLURM_ARRAY_TASK_ID"

# Load necessary modules - check what you have installed on your server vs. what is in your bash
# module load fastqc
# module load cutadapt
# module load star
# module load samtools
# module load htseq
# module load multiqc

# Create directory for FastQC reports
mkdir fastqc_reports

# Create directory for trimmed fastq files
mkdir trimmed_fastq

# Run FastQC on all input FASTQ files and perform adapter trimming with TrimGalore
for f in *_R1_001.fastq.gz; do  #check the base name of your files and modify as needed
base=$(basename ${f} _R1_001.fastq.gz)
fastqc -o fastqc_reports ${base}_R1_001.fastq.gz ${base}_R2_001.fastq.gz; # Generate FastQC report
trim_galore --paired --illumina --fastqc --output_dir trimmed_fastq ${base}_R1_001.fastq.gz ${base}_R2_001.fastq.gz; # Trim adapters using TrimGalore
done 

# Make a directory for the bam files
mkdir bam_files

# Run STAR on the trimmed FASTQ files
for f in trimmed_fastq/*_R1_001_val_1.fq.gz; do
  base=$(basename $f _R1_001_val_1.fq.gz); # Extract basename of input file
  r2="$base""_R2_001_val_2.fq.gz"
STAR --runThreadN 12 \
     --genomeDir /home/langeca/gilli431/software/STAR_hg38 \
     --readFilesCommand zcat \
     --readFilesIn $f trimmed_fastq/$r2 \
     --outFileNamePrefix bam_files/${base}_ \
     --outSAMtype BAM \

# Sort and index the BAM files
samtools sort -o bam_files/${base}_sorted.bam bam_files/${base}_Aligned.sortedByCoord.out.bam
samtools index bam_files/${base}_sorted.bam

# Make a directory for the count files
mkdir count_files

# Generate count files using HTSeq
htseq-count -f bam -r name -s reverse -m union -i gene_id bam_files/${base}_sorted.bam ~/software/gencode.v38.primary_assembly.annotation.gtf > count_files/${base}.counts

done

# Run MultiQC on the FastQC reports, trimmed FASTQ files, sorted BAM files, and count files
multiqc fastqc_reports trimmed_fastq bam_files count_files

######## Annotated Slurm script for Processing RNA-seq Data from .fastq to .cnts #########
#### Author: Noelle Gillis, PhD
#### Date Modified: 2/22/23
