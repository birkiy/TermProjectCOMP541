# SingledMapping rule with bowtie2

idx = config["hg19"]["idx"]["bowtie2"]

rule SingleMapping:
        input:
                U="links/{raw}.fastq.gz"
        output:
                bam="results/mapping/{raw}.raw.bam"
        message:
                "Executing SingleMapping rule with bowtie2 rule for {wildcards.raw}"
        threads:
                16
        params:
                ""
        shell:
                """
                bowtie2 -x {idx} --threads {threads} -q {input.U} {params} | \
                samtools view -bS - > {output.bam}
                """
