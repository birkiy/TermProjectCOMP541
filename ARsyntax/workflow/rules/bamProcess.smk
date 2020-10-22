



rule bamProcess:
        input:
                "results/mapping/{raw}.bam"
        output:
                bai="results/mapping/processed/{raw}.bam.bai",
                bam="results/mapping/processed/{raw}.final.bam"

        threads:
                16
        message:
                "Executing bamProcess rule for {wildcards.raw}"
        shell:
                """
                echo "\n bamProcess {input} \n"

                cat <(samtools view -H {input}) <(samtools view -q 30 -F 1804 {input}) | \
                samtools sort -@ {threads} -m 10G -n - | \
                samtools fixmate -m -@ {threads} - - | \
                samtools sort -@ {threads} -m 10G - | \
                samtools markdup -r - - | \
                samtools view -b - > {output.bam}

                samtools index  -@ {threads} {output.bam} {output.bai}

                samtools view -b  {output.bam} | wc -l
                """
