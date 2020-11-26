



def getRepsToConcat(wildcards):
        if wildcards.raw.find("control") > 0:
                raw = wildcards.raw.rsplit(".", 1)[0]
                lib = controlDF.loc[controlDF["Raw"] == raw, "Library"].to_list()[0]
                SRR = list(controlDF.loc[
                        (controlDF["Raw"] == raw) &
                        (controlDF["Run"] == wildcards.run),
                        "SRR"])
        elif wildcards.raw.find("control") == -1:
                lib = sampleDF.loc[sampleDF["ExperimentSRX"] == wildcards.raw, "Library"].to_list()[0]
                SRR = list(sampleDF.loc[
                        (sampleDF["ExperimentSRX"] == wildcards.raw) &
                        (sampleDF["Run"] == wildcards.run),
                        "SRR"])
        if wildcards.run == "U" or wildcards.run == "R1":
                return expand("raw/{srr}_1.fastq.gz", srr=SRR)
        elif wildcards.run == "R2":
                return expand("raw/{srr}_2.fastq.gz", srr=SRR)


rule ConcatFastq:
        input:
                getRepsToConcat
        output:
                "raw/{raw}.{run}.fastq.gz"
        message:
                "Executing ConcatFastq rule for {wildcards}"
        threads:
                4
        shell:
                """
                zcat {input} > {output}
                """
