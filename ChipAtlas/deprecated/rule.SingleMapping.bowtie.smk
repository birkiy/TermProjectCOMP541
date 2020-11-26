# SingledMapping rule with bowtie

idx = config["hg19"]["idx"]["bowtie"]

rule SingleMapping:
        input:
                U="links/{raw}.R1.fastq.gz"
        output:
                U=temp("links/{raw}.fastq")
                bam="results/mapping/{raw}.raw.bam"
        message:
                "Executing SingleMapping rule with bowtie rule for {wildcards.raw}"
        threads:
                16
        params:
                ""
        shell:
                """
                gzip -dc {input} > {output.U}
                bowtie -x {idx} --threads {threads} -q {output.U} -S {params} | \
                samtools view -bS - > {output.bam}
                """
