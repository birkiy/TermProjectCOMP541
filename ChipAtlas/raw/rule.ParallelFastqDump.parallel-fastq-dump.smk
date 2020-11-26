


def getSRA(wildcards):
        lib = srrDF.loc[srrDF["SRR"] == wildcards.SRA, "Library"].to_list()[0]
        return f"SRA/{wildcards.SRA}/{wildcards.SRA}.sra"


rule ParallelFastqDump:
        input:
                getSRA
        output:
                R1="raw/{SRA}_1.fastq.gz",
                R2="raw/{SRA}_2.fastq.gz",
        threads:
                16
        message:
                "Executing parallelFastqDump for {wildcards.SRA} with {threads} cores!"
        run:
                lib = srrDF.loc[srrDF["SRR"] == wildcards.SRA, "Library"].to_list()[0]
                if lib == "Single":
                        shell("""
                        echo {params}
                        parallel-fastq-dump -t {threads} --split-files --gzip -s {input} -O raw
                        touch {output.R2}
                        """)
                elif lib == "Paired":
                        shell("""
                        echo {params}
                        parallel-fastq-dump -t {threads} --split-files --gzip -s {input} -O raw
                        """)
