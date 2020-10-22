


folder = "results/mapping/processed"
blacklistFile = config["blacklist"]

rule sumBigwigs:
        input:
                rep1="results/mapping/processed/{raw}.rep1.{strand}.5end.bigWig",
                rep2="results/mapping/processed/{raw}.rep2.{strand}.5end.bigWig"
        output:
                "results/mapping/processed/{raw}.{strand}.5end.bigWig"
        shell:
                """
                bigwigCompare -b1 {input.rep1} \
                    -b2 {input.rep2} \
                    --operation add --blackListFileName {blacklistFile} -p 40 \
                    -bs=1 -o {output}
                """
