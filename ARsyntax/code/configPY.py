

# import sys
# print(f"Using python version:{sys.version}")

import pandas as pd

sampleDF = pd.read_table("code/samples.tsv", dtype=str).set_index(["SampleName"], drop=False)
sampleDF = sampleDF.sort_index()

sampleDF["Pseudo"] = sampleDF["SampleName"].str.replace("rep", "pseudo")

sampleDF["Raw"] = sampleDF["SampleName"].str.replace(r".rep[1-2]", "")

plots = [
    f"coverage/{raw}.pdf"
    for raw in set(sampleDF["Raw"])
]


desiredOutputList = plots
