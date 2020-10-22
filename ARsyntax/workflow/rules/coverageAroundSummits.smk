

rule coverageAroundSummits:
        input:
                summits=expand("results/peak/idr/{{raw}}.{rep}.summits.bed", rep=["rep", "pseudo"]),
                forwardBW="results/bigwig/{raw}.merged.+.5end.bigWig",
                reverseBW="results/bigwig/{raw}.merged.-.5end.bigWig"
        output:
                npz=temp("results/coverage/{raw}.npz"),
                pdf="results/coverage/{raw}.pdf"
        threads:
                16
        message:
                "Executing coverageAroundSummits rule for {wildcards.raw}"
        shell:
                """
                computeMatrix reference-point -S \
                {input.forwardBW} \
                {input.reverseBW} \
                -R {input.summits} \
                --referencePoint=center\
                -a 1000 -b 1000 \
                --sortRegions descend -p {threads} \
                -o {output.npz}

                plotHeatmap -m {output.npz} \
                --whatToShow 'heatmap and colorbar' \
                --colorMap "Blues" --missingDataColor 1 \
                --sortRegions descend \
                --heatmapHeight 20 --heatmapWidth 7 \
                -out {output.pdf}
                """
