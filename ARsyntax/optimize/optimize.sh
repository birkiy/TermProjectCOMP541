
"""
##########################
#                        #
#  Umut Berkay Altıntaş  #
#                        #
##########################
"""

conda install -c conda-forge mamba

mamba create -c conda-forge -c bioconda -n ARsyntax \
  python=3.8 \
  snakemake=5.26.1 \
  bowtie=1.3.0 \
  samtools=1.11 \
  bedtools=2.29.2 \
  macs2=2.2.7.1 \
  idr=2.0.4.2 \
  deeptools=3.5.0 \
  ucss-bedGraphToBigWig=377 \
  parallel-fastq-dump=0.6.6



```
DATA PROCESSING
```

"""
Unzip
"""
gzip -dc {input.R1} > {output.R1}
gzip -dc {input.R2} > {output.R2}

"""
Mapping:
  Bowtie (bowtie-align-s version 1.3.0)
  -k: reports only <int> number of aligned reads.
  -v: allows only <int> number of mismatches.
  -m: supresses the reports if their reads are aligned more than <int> times.
  --strata: "stranum" is a breadth of alignment according to their mismatches(if -v is sepecified)
            For example, one read has 5 alignments and one of them has 0 mismatches,
            while other two have 1 mismatch, and rest have 2 mismatches.
            In this case, there are 3 strata.
            Specifiying this parameter selects the best stranum among all.
  --best: sorts reports in terms of their stranum.

Convert Sam to Bam
"""
bowtie --chunkmbs 512 -k 1 -m 1 -v 2 --best --strata {idx} --threads {threads} -q -1 {output.R1} -2 {output.R2} -S | \
  samtools view -bS - > {output.bam}



"""
Filtering Bam (alignment files):
  Samtools (Version: 1.11)
  Filter
    => Concatanate header and filter (MAPQ < 30) and (1804 flags)
  Remove Duplicates
    => sort by name => fixmates => sort by coordinate => markdup and remove them.
"""
cat <(samtools view -H {input}) <(samtools view -q 30 -F 1804 {input}) | \
  samtools sort -@ {threads} -m 10G -n - | \
  samtools fixmate -m -@ {threads} - - | \
  samtools sort -@ {threads} -m 10G - | \
  samtools markdup -r - - | \
  samtools view -b - > {output.bam}

samtools index  -@ {threads} {output.bam} {output.bai}

samtools view -b  {output.bam} | wc -l


"""
Generate BigWigs:

  bedtools (Version: v2.29.2)
    genomecov
     -5: signal at 5' end of reads.
     -bg: reports BedGraph format
     -strand: calculates <+/-> strand
     -scale: scales the depth value with N(which is total read amount)
    sort
      sorts the bedgraph
    intersect
      -v: gives from first file that is not overlapping in the second file

  bedGraphToBigWig (377)
    converts bedgraphs into bigwig files.

"""
N=$((`samtools view {input.bam} | wc -l `))

bedtools genomecov -5 -bg -strand + -ibam {input.bam} -scale `bc -l <<< 100000000/$N` | bedtools sort > {output.forwardBG}
echo "Number of reads:"`wc -l {output.forwardBG}`
bedtools intersect -v -a {output.forwardBG} -b {blacklistFile} > {output.forwardBGblk}
echo "Number of reads:"`wc -l {output.forwardBGblk}`
bedGraphToBigWig {output.forwardBGblk} {chrSize} {output.forwardBW}

bedtools genomecov -5 -bg -strand - -ibam {input.bam} -scale `bc -l <<< 100000000/$N` | bedtools sort > {output.reverseBG}
echo "Number of reads:"`wc -l {output.reverseBG}`
bedtools intersect -v -a {output.reverseBG} -b {blacklistFile} > {output.reverseBGblk}
echo "Number of reads:"`wc -l {output.reverseBGblk}`
bedGraphToBigWig {output.reverseBGblk} {chrSize} {output.reverseBW}


"""
Peak Calling:
  Macs2(macs2 2.2.7.1)
    callpeak
      -f: format of given file
          BAMPE is for paired end sequencing
      -g: genome size of given specie, hs is built-in
      -q: minimum FDR cutoff
      --shift:
"""
macs2 callpeak \
  -t {input} \
  -n {wildcards.raw} \
  -f BAMPE -g hs -q 0.05 \
  --outdir results/peak \
  --shift -75 --extsize 150 2> {log} # according to article reads on each strand are extended with these parameters
sort -k8,8nr {output.summits} > {output.sortedSummits}
bedtools intersect -v -a {output.sortedSummits} -b {blacklistFile} >  {output.filteredSummits}



"""
Irreproducible Discovery Rate (IDR) framework
  idr (2.0.4.2)
    --input-file-type: type of input, although they specifies that they can accept
                       bed files (summits for examples), program crushes. Also,
                       doesn't allow to specify --rank with 5th column (which is score)
  awk (GNU Awk 4.0.2)
  => convert idr output into summits bed file
  'chr  summit  summit+1  name  signal'
"""
idr --samples {input} \
  --input-file-type narrowPeak \
  --output-file {output.idrOut} \
  --plot
awk '{{if($5 >= 540) print $0}}' {output.idrOut} | wc -l
awk '{{if($5 >= 540) print $1"\t"$2+$10"\t"$2+$10+1"\t{wildcards.raw}."NR"\t"$7}}' {output.idrOut} > {output.summits}


"""
Coverage Heatmaps
  DeepTools (deeptools 3.5.0)
    computeMatrix reference-point: considers centers of bed intervals
      -S: input bigwig files
      -R: input bed files
      --referencePoint=center: aligns the center points of intervals to the center.
      -a/-b: +/- bp distance from center point
      --sortRegions: sorts regions accordingly
    plotHeatmap
      -m: calculated matrix through computeMatrix
      --whatToShow: what to show :)
      --colorMap: others "https://matplotlib.org/3.1.0/tutorials/colors/colormaps.html"
      --heatmapHeight/--heatmapWidth: consider individual heatmaps (so if 2 heatmaps 7*2 is the image size)
"""
computeMatrix reference-point -S \
  {input.forwardBW} \
  {input.reverseBW} \
  -R {input.summits} \
  --referencePoint=center\
  -a 1000 -b 1000 \
  --sortRegions descend -p {threads} \
  -o {output.npz}

plotHeatmap -m {output.npz} \
  --whatToShow 'heatmap and colorbar' \
  --colorMap "Blues" --missingDataColor 1 \
  --sortRegions descend \
  --heatmapHeight 20 --heatmapWidth 7 \
  -out {output.pdf}
#######################################








#!/bin/bash
#SBATCH --job-name=optimize
#SBATCH --time=06:00:00
#SBATCH --mem-per-cpu=12G
#SBATCH --cpus-per-task=30
#SBATCH --export=all
#SBATCH -p long




N=$((`samtools view LNCaP.dht.AR.rep1.bam | wc -l `))


bedtools genomecov -bg -strand + -ibam LNCaP.dht.AR.rep1.final.bam -scale `bc -l <<< 100000000/$N` | bedtools sort > LNCaP.dht.AR.rep1.N.+.bedGraph
echo "Number of reads:"`wc -l  LNCaP.dht.AR.rep1.N.+.bedGraph`
bedtools intersect -v -a  LNCaP.dht.AR.rep1.N.+.bedGraph -b /home/ualtintas/genomeAnnotations/ENCFF001TDO.bed >  LNCaP.dht.AR.rep1.N.+.blk.bedGraph
echo "Number of reads:"`wc -l LNCaP.dht.AR.rep1.N.+.blk.bedGraph`
bedGraphToBigWig LNCaP.dht.AR.rep1.N.+.blk.bedGraph /home/ualtintas/genomeAnnotations/hg19.chrom.sizes LNCaP.dht.AR.rep1.N.+.blk.bigWig

bedtools genomecov -bg -strand - -ibam LNCaP.dht.AR.rep1.final.bam -scale `bc -l <<< 100000000/$N` | bedtools sort > LNCaP.dht.AR.rep1.N.-.bedGraph
echo "Number of reads:"`wc -l LNCaP.dht.AR.rep1.N.-.bedGraph`
bedtools intersect -v -a LNCaP.dht.AR.rep1.N.-.bedGraph -b /home/ualtintas/genomeAnnotations/ENCFF001TDO.bed > LNCaP.dht.AR.rep1.N.-.blk.bedGraph
echo "Number of reads:"`wc -l LNCaP.dht.AR.rep1.N.-.blk.bedGraph`
bedGraphToBigWig LNCaP.dht.AR.rep1.N.-.blk.bedGraph /home/ualtintas/genomeAnnotations/hg19.chrom.sizes LNCaP.dht.AR.rep1.N.-.blk.bigWig





bedtools genomecov -3 -bg -strand + -ibam LNCaP.dht.AR.rep1.final.bam -scale `bc -l <<< 100000000/$N` | bedtools sort > LNCaP.dht.AR.rep1.3.+.bedGraph

bedtools intersect -v -a LNCaP.dht.AR.rep1.3.+.bedGraph -b /home/ualtintas/genomeAnnotations/ENCFF001TDO.bed > LNCaP.dht.AR.rep1.3.+.blk.bedGraph

bedGraphToBigWig  LNCaP.dht.AR.rep1.3.+.blk.bedGraph /home/ualtintas/genomeAnnotations/hg19.chrom.sizes  LNCaP.dht.AR.rep1.3.+.blk.bigWig

bedtools genomecov -3 -bg -strand - -ibam LNCaP.dht.AR.rep1.final.bam -scale `bc -l <<< 100000000/$N` | bedtools sort > LNCaP.dht.AR.rep1.3.-.bedGraph

bedtools intersect -v -a LNCaP.dht.AR.rep1.3.-.bedGraph -b /home/ualtintas/genomeAnnotations/ENCFF001TDO.bed > LNCaP.dht.AR.rep1.3.-.blk.bedGraph

bedGraphToBigWig LNCaP.dht.AR.rep1.3.-.blk.bedGraph /home/ualtintas/genomeAnnotations/hg19.chrom.sizes LNCaP.dht.AR.rep1.3.-.blk.bigWig
