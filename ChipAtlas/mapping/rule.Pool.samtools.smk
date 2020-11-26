





def getRepsToPool(wildcards):
        reps = list(sampleDF.loc[sampleDF["SampleName"] == wildcards.sampleName, "Replicate"])
        return expand("results/mapping/{{sampleName}}.{rep}.final.bam", rep=reps)



rule Pool:
        input:
                getRepsToPool
        output:
                bam="results/mapping/{sampleName}.merged.final.bam",
                bai="results/mapping/{sampleName}.merged.final.bam.bai"
        message:
                "Executing pool rule for {wildcards.sampleName}"
        threads:
                16
        shell:
                """
                samtools merge -@ {threads} -u {output.bam} {input}

                samtools index  -@ {threads} {output.bam} {output.bai}
                """
