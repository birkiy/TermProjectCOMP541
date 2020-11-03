#!/bin/bash
#SBATCH --job-name=ARsyntax.download
#SBATCH --time=06:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=30
#SBATCH --export=all
#SBATCH -p long


echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE43785"

parallel-fastq-dump -t 30 --gzip --split-files -s SRR653215
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653216
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653219
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653220
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653223
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653224
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653225
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653226
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653227
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653228
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653229
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653230
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653231
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653232
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653233
parallel-fastq-dump -t 30 --gzip --split-files -s SRR653234


echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE99378"

parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626407
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626408
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626409
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626410
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626413
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626414
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626415
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626416

parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626411
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626412
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626417
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626418
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626431
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626432
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626433
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626434
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626435
parallel-fastq-dump -t 30 --gzip --split-files -s SRR5626436


echo "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE143906"

parallel-fastq-dump -t 30 --gzip --split-files -s SRR10913257
parallel-fastq-dump -t 30 --gzip --split-files -s SRR10913258
