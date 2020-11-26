


rule SRAprefetch:
        output:
                "SRA/{SRA}/{SRA}.sra"
        message:
                "Prefetch {wildcards.SRA}"
        shell:
                """
                prefetch -O SRA {wildcards.SRA}
                """
