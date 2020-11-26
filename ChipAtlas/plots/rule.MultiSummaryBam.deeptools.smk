

blacklistFile = config["hg19"]["blacklist"]

def getAll(wildcards):
        if wildcards.samples == "merged":
                samples = set(sampleDF["SampleName"] + ".merged")
        elif wildcards.samples == "rep":
                samples = sampleDF["Raw"]
        return expand("results/mapping/{sample}.final.bam", sample=samples)


rule MultiBamSummary:
        input:
                samples=getAll,
                bed="/groups/lackgrp/ll_members/berkay/STARRbegin/peaks/totalGRE.bed"
        output:
                rawCounts="results/coverage/countTableRaw.{samples}.txt",
                matrix="results/coverage/count-table-deeptools.{samples}.npz"
        threads:
                32
        message:
                "Executing MultiBamSummary rule"
        shell:
                """
                multiBamSummary BED-file \
                --BED {input.bed} \
                --bamfiles {input.samples} \
                --extendReads 150 \
                --centerReads \
                -p {threads} \
                --outRawCounts {output.rawCounts} -out {output.matrix}
                """
