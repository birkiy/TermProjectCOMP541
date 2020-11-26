


import pandas as pd


sampleDF = pd.read_table("code/samples.tsv")

controlDF = pd.read_table("code/controls.tsv")

srrDF = pd.concat(
    [
        controlDF[["SRR", "Library"]],
        sampleDF[["SRR", "Library"]]
    ]
)


bigWigs = [
    f"results/bigwig/{raw}.{type}.bigWig"
    for raw in sampleDF["Raw"]
    for type in ["RPKM", "SES", "genomcov"]
]


bigWigsMerged = [
    f"results/bigwig/{raw}.merged.{type}.bigWig"
    for raw in sampleDF["SampleName"]
    for type in ["genomcov"]
]

plotCorrelation = [
    f"results/plots/correlation.{samples}.{corr}.{plot}.pdf"
    for samples in ["rep", "merged"]
    for corr in ["pearson", "spearman"]
    for plot in ["scatterplot", "heatmap"]
]

plotFingerprint = [
    f"results/plots/fingerprint.{samples}.pdf"
    for samples in ["rep", "merged"]
]

desiredOutputList = bigWigs + plotCorrelation + plotFingerprint + bigWigsMerged
