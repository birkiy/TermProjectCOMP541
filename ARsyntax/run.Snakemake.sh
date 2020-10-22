#!/bin/bash


snakemake \
  --snakefile code/Snakefile \
  --configfile code/config.yaml \
  --unlock


# snakemake version: 5.26.1

snakemake \
  --snakefile code/Snakefile \
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
      --output 'slurms/%j.out' \
      --error 'slurms/%j.err'"



snakemake \
  --snakefile code/Snakefile \
  --configfile code/config.yaml \
  -n --dag | dot -Tpdf > ARsyntaxSamples.pdf


snakemake \
  --snakefile code/Snakefile \
  --configfile code/config.yaml \
  -n --forceall --rulegraph | dot -Tpdf > ARsyntaxRule.pdf
