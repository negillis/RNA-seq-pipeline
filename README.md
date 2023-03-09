# RNA-seq-pipeline
RNA-seq processing pipeline and instructions for use

If you are here looking for a simple guide to processing your RNA-seq data, you have come to the right place! 

Step one: Make sure that you have the correct software installed!
  1. fastqc
  2. cutadapt
  3. trimGalore
  4. STAR
  5. samtools
  6. HT-seq
  7. multiqc

Step two: Download the RNA-seq_pipeline_slurm.sh file and place it in the folder where your raw data (.fastq) files are.

Step three: Modify the file so it emails you progress updates.
Add your email to this line: #SBATCH --mail-user= youremail.here@umn.edu  

Step four: Run the pipeline!
  sbatch RNA-seq_pipeline_slurm.sh
