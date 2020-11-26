



rule PlotCorrelation:
        input:
                "results/coverage/count-table-deeptools.{samples}.npz"
        output:
                "results/plots/correlation.{samples}.{corr}.{plot}.pdf"
        message:
                "Executing MultiBamSummary {wildcards.plot} plot for {wildcards.samples} samples with {wildcards.corr} correlation."
        shell:
                """
                plotCorrelation \
                --corData {input} \
                --corMethod {wildcards.corr} \
                --whatToPlot {wildcards.plot} \
                --plotFile {output}
                """
