
idx = config["reference"]["idx"]

rule mapping:
        input:
                R1="rawData/{raw}.R1.fastq.gz",
                R2="rawData/{raw}.R2.fastq.gz"
        output:
                R1=temp("rawData/{raw}.R1.fastq"),
                R2=temp("rawData/{raw}.R2.fastq"),
                bam="results/mapping/{raw}.bam"
        message:
                "Executing mappingExo rule for {wildcards.raw}"
        threads:
                16
        shell:
                """
                echo "\n mapping {input.R1} and {input.R2}"

                gzip -dc {input.R1} > {output.R1}
                gzip -dc {input.R2} > {output.R2}
                bowtie --chunkmbs 512 -k 1 -m 1 -v 2 --best --strata {idx} --threads {threads} -q -1 {output.R1} -2 {output.R2} -S | \
                samtools view -bS - > {output.bam}
                """
