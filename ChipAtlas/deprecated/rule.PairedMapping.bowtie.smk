# PairedMapping rule with bowtie

idx = config["hg19"]["idx"]["bowtie"]

rule PairedMapping:
        input:
                R1="links/{raw}.R1.fastq.gz",
                R2="links/{raw}.R2.fastq.gz"
        output:
                R1=temp("links/{raw}.R1.fastq"),
                R2=temp("links/{raw}.R2.fastq"),
                bam="results/mapping/{raw}.raw.bam"
        message:
                "Executing PairedMapping rule with bowtie for {wildcards.raw}"
        threads:
                16
        params:
                ""
        shell:
                """
                gzip -dc {input.R1} > {output.R1}
                gzip -dc {input.R2} > {output.R2}
                bowtie -x {idx} --threads {threads} -q -1 {output.R1} -2 {output.R2} -S {params} | \
                samtools view -bS - > {output.bam}
                """
