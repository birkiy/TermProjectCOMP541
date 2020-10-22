
chrSize = config["reference"]["chrSize"]

blacklistFile = config["blacklist"]

rule SignalAt5end:
        input:
                # rules.mapping.bamProcess.output
                bam="results/mapping/processed/{raw}.final.bam"
        output:
                forwardBG=temp("results/bigwig/{raw}.+.5end.bedGraph"),
                forwardBGblk=temp("results/bigwig/{raw}.+.5end.blk.bedGraph"),
                forwardBW="results/bigwig/{raw}.+.5end.bigWig",
                reverseBG=temp("results/bigwig/{raw}.-.5end.bedGraph"),
                reverseBGblk=temp("results/bigwig/{raw}.-.5end.blk.bedGraph"),
                reverseBW="results/bigwig/{raw}.-.5end.bigWig"
        threads:
                4
        message:
                "Executing SignalAt5end rule for {wildcards.raw}"
        shell:
                """
                echo "{input.bam}"
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
