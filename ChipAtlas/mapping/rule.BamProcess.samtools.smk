# BamProcess rule

rule BamProcess:
        input:
                bam="results/mapping/{raw}.raw.bam"
        output:
                bam="results/mapping/{raw}.final.bam",
                bai="results/mapping/{raw}.final.bam.bai"
        threads:
                16
        message:
                "Executing BamProcess rule for {wildcards.raw}"
        params:
                "" # Note that you can add parameters as "-q 30 -F 1804"
        shell:
                """
                N=$((`samtools view {input.bam} | wc -l `))
                echo "Number of reads before bam filtration:"$N

                cat <(samtools view -H {input.bam}) <(samtools view {params} {input.bam}) | \
                samtools sort -@ {threads} -m 10G -n - | \
                samtools fixmate -m -@ {threads} - - | \
                samtools sort -@ {threads} -m 10G - | \
                samtools markdup - - | \
                samtools view -b -r - > {output.bam}

                samtools index  -@ {threads} {output.bam} {output.bai}

                N=$((`samtools view {output.bam} | wc -l `))
                echo "Number of reads after bam filtration:"$N
                """
