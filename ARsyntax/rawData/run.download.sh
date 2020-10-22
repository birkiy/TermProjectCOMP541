#!/bin/bash
#SBATCH --job-name=star.download
#SBATCH --time=06:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=30
#SBATCH --export=all
#SBATCH -p long


echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE43785"

parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653215
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653216
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653219
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653220
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653223
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653224
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653225
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653226
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653227
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653228
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653229
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653230
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653231
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653232
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653233
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR653234


echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE99378"

parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626416
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626415
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626414
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626413
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626407
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626408
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626409
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR5626410


echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE143906"

parallel-fastq-dump -t 30 --gzip --split-3 -s SRR10913257
parallel-fastq-dump -t 30 --gzip --split-3 -s SRR10913258
