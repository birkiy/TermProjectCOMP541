#!/bin/bash
#SBATCH --job-name=run.snakemake
#SBATCH --time=3-00:00:00
#SBATCH --mem-per-cpu=5G
#SBATCH --cpus-per-task=2
#SBATCH --export=all
#SBATCH -p long

snakemake \
  --snakefile Snakefile \
  --configfile code/config.yaml \
  --unlock -j1

snakemake \
  --snakefile Snakefile \
  --configfile code/config.yaml \
  -n --dag | dot -Tpdf > Samples.pdf


# snakemake version: 5.26.1

snakemake \
  --snakefile Snakefile \
  --configfile code/config.yaml \
  -j100 \
  --cluster-config code/cluster.yaml  \
  --rerun-incomplete \
  --use-conda \
  --cluster "sbatch \
      -A {cluster.partition} \
      -c {cluster.c} \
      -t {cluster.time} \
      --mem {cluster.mem} \
      -o logsSlurm/{rule}_{wildcards} \
      -e logsSlurm/{rule}_{wildcards} "


snakemake \
  --snakefile Snakefile \
  --configfile code/config.yaml \
  -j1 -r -n
