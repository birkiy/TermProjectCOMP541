

blacklistFile = config["hg19"]["blacklist"]

def getAll(wildcards):
        if wildcards.samples == "merged":
                samples = set((sampleDF["SampleName"] + ".merged").to_list() + (controlDF["Raw"] + ".control").to_list())
        elif wildcards.samples == "rep":
                samples = set(sampleDF["Raw"].to_list() + (controlDF["Raw"] + ".control").to_list())
        return expand("results/mapping/{sample}.final.bam", sample=samples)


rule PlotFingerprint:
        input:
                getAll
        output:
                "results/plots/fingerprint.{samples}.pdf"
        message:
                "Executing PlotFingerprint for {wildcards.samples}."
        shell:
                """
                plotFingerprint \
                -b {input} \
                --extendReads 150 \
                --centerReads \
                -plot {output}
                """
