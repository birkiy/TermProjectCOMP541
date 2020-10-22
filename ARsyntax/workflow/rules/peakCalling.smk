

blacklistFile = config["blacklist"]


rule peakCalling:
        input:
                "results/mapping/processed/{raw}.final.bam",
        output:
                peaks="results/peak/{raw}_peaks.narrowPeak",
                sortedPeaks=temp("results/peak/idr/{raw}.sorted.narrowPeak"),
                filteredPeaks="results/peak/idr/{raw}.filtered.narrowPeak"
        message:
                "Executing peakCalling rule for {wildcards.raw}"
        shell:
                """
                # Peaks are calculated across pairs with BAMPE (see manual)
                # name of the sample
                macs2 callpeak \
                    -t {input} \
                    -n {wildcards.raw} \
                    -f BAMPE -g hs -q 0.05 \
                    --outdir results/peak \
                    --shift -75 --extsize 150 # according to article reads on each strand are extended with these parameters
                sort -k8,8nr {output.peaks} > {output.sortedPeaks}
                bedtools intersect -v -a {output.sortedPeaks} -b {blacklistFile} >  {output.filteredPeaks}
                """
