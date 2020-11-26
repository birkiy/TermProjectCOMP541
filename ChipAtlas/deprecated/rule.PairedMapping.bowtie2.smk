# PairedMapping rule with bowtie2

idx = config["hg19"]["idx"]["bowtie2"]

rule PairedMapping:
        input:
                R1="links/{raw}.R1.fastq.gz",
                R2="links/{raw}.R2.fastq.gz"
        output:
                bam="results/mapping/{raw}.raw.bam"
        message:
                "Executing PairedMapping rule with bowtie2 for {wildcards.raw}"
        threads:
                16
        params:
                ""
        shell:
                """
                bowtie2 -x {idx} --threads {threads} -q -1 {input.R1} -2 {input.R2} {params} | \
                samtools view -bS - > {output.bam}
                """
