

rule idr:
        input:
                expand("results/peak/idr/{{raw}}{rep}.filtered.narrowPeak", rep=["1", "2"])
        output:
                idrOut="results/peak/idr/{raw}.idr",
                summits="results/peak/idr/{raw}.summits.bed"
        message:
                "Executing idr rule for {wildcards.raw}"
        shell:
                """
                idr --samples {input} \
                --input-file-type narrowPeak \
                --output-file {output.idrOut} \
                --plot

                awk '{{if($5 >= 540) print $0}}' {output.idrOut} | wc -l

                awk '{{if($5 >= 540) print $1"\t"$2+$10"\t"$2+$10+1"\t{wildcards.raw}."NR"\t"$7}}' {output.idrOut} > {output.summits}
                """
