


chrSize = config["hg19"]["chrSize"]

blacklistFile = config["hg19"]["blacklist"]

rule GenerateBigWig:
        input:
                bam="results/mapping/{raw}.final.bam"
        output:
                BG=temp("results/bigwig/{raw}.bedGraph"),
                BGblk=temp("results/bigwig/{raw}.blk.bedGraph"),
                BW="results/bigwig/{raw}.genomcov.bigWig",
        threads:
                4
        message:
                "Executing GenerateBigWig rule with bedtools for {wildcards.raw}."
        shell:
                """
                N=$((`samtools view {input.bam} | wc -l `))
                echo "Number of reads for coverage:"$N
                bedtools genomecov -bg -ibam {input.bam} -scale `bc -l <<< 1000000/$N` | bedtools sort > {output.BG}

                echo "Number of regions covered:"`wc -l {output.BG}`
                bedtools intersect -v -a {output.BG} -b {blacklistFile} > {output.BGblk}

                echo "Number of regions w/o blacklist:"`wc -l {output.BGblk}`
                bedGraphToBigWig {output.BGblk} {chrSize} {output.BW}
                """
