

def getRepsForIDR(wildcards):
        trueSamples = list(sampleDF.loc[sampleDF["Raw"] == ".".join(wildcards.raw.split(".")[0:-1]), "Replicate"])
        repIdx = [r[-1] for r in trueSamples]
        return expand("results/peak/idr/{{raw}}{rep}.filtered.narrowPeak", rep=repIdx)

rule idr:
        input:
                getRepsForIDR
                #expand("results/peak/idr/{{raw}}{rep}.filtered.narrowPeak", rep=["1", "2"])
        output:
                idrOut="results/peak/idr/{raw}.idr",
                summits="results/peak/idr/{raw}.summits.bed"
        message:
                "Executing idr rule for {wildcards.raw}"
        run:
                trueSamples = list(sampleDF.loc[sampleDF["Raw"] == ".".join(wildcards.raw.split(".")[0:-1]), "Replicate"])
                repIdx = [r[-1] for r in trueSamples]
                if len(repIdx) < 2:
                        print("Not enough replicates for {wildcards.raw}")
                else:
                        shell(
                        """
                        idr --samples {input} \
                        --input-file-type narrowPeak \
                        --output-file {output.idrOut} \
                        --plot

                        awk '{{if($5 >= 540) print $0}}' {output.idrOut} | wc -l

                        awk '{{if($5 >= 540) print $1"\t"$2+$10"\t"$2+$10+1"\t{wildcards.raw}."NR"\t"$7}}' {output.idrOut} > {output.summits}

                        sed -i '/_/d' ./{output.summits}
                        """
                        )
