

folder = "results/mapping/processed"
rule pseudoReplicates:
        input:
                "results/mapping/processed/{raw}.merged.final.bam"
        output:
                header=temp("results/mapping/processed/{raw}.merged.header.final.sam"),
                pseudo1="results/mapping/processed/{raw}.pseudo1.final.bam",
                pseudo2="results/mapping/processed/{raw}.pseudo2.final.bam"
        message:
                "Executing pseudoReplicates rule for {wildcards.raw}"
        shell:
                """
                samtools view -H {input} > {output.header}

                #Split merged treatments
                nlines=$(samtools view {input} | wc -l )
                nlines=$(( (nlines + 1) / 2 )) # half that number

                samtools view {input} | shuf - | split -d -l $nlines - "{folder}/{wildcards.raw}"

                cat {output.header} {folder}/{wildcards.raw}00 | \
                    samtools view -bS - > {output.pseudo1}
                cat {output.header} {folder}/{wildcards.raw}01 | \
                    samtools view -bS - > {output.pseudo2}
                """


rule pool:
        input:
                expand("results/mapping/processed/{{raw}}.{rep}.final.bam", rep=["rep1", "rep2"])
        output:
                "results/mapping/processed/{raw}.merged.final.bam"
        message:
                "Executing pool rule for {wildcards.raw}"
        threads:
                16
        shell:
                """
                #Merge treatment BAMS
                samtools merge -@ {threads} -u {output} {input}
                """
