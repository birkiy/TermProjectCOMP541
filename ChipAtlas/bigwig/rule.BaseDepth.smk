




bedtools genomecov -d -ibam A549.GR.dex.0h.merged.final.bam -scale `bc -l <<< 1000000/$N` | bedtools sort > {output.BG}



blacklistFile = config["hg19"]["blacklist"]

rule BaseDepth:
        input:
                "results/mapping/{sampleName}.merged.final.bam"
        output:
                "results/bigWig/{type}/{sampleName}.bedGraph"
        shell:
                """
                bedtools genomecov -bg -strand + -ibam {input.bam} -scale `bc -l <<< 1000000/$N` | bedtools sort > {output.BG}
