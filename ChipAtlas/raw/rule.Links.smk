# Links rule
## Note to define a sampleDF in configPY.py

def linkFrom(wildcards):
        if wildcards.raw.find("control") > 0:
                raw = wildcards.raw.rsplit(".", 1)[0]
                RAW = controlDF.loc[
                        (controlDF["Raw"] == raw) &
                        (controlDF["Run"] == wildcards.run),
                        "Raw"].to_list()
                RAW = [_+".control" for _ in RAW]
        elif wildcards.raw.find("control") == -1:
                replicate = wildcards.raw.rsplit(".", 1)[-1]
                if replicate == "merged":
                        return ""
                else:
                        RAW = sampleDF.loc[
                                (sampleDF["Raw"] == wildcards.raw) &
                                (sampleDF["Run"] == wildcards.run),
                                "ExperimentSRX"].to_list()
        if wildcards.run == "U" or wildcards.run == "R1":
                return f"raw/{RAW[0]}.{{run}}.fastq.gz"
        elif  wildcards.run == "R2":
                return f"raw/{RAW[0]}.{{run}}.fastq.gz"





rule Links:
        input:
                linkFrom
        output:
                linkTo="links/{raw}.{run}.fastq.gz"
        message:
                "Executing Links rule from {input} to {output.linkTo}"
        shell:
                """
                ln -s ../{input} {output.linkTo}
                """



#
# def linkFromControl(wildcards):
#         control = controlDF.loc[
#                 (controlDF["Raw"] == wildcards.control),
#                 "Raw"].to_list()[0]
#         if wildcards.run == "U" or wildcards.run == "R1":
#                 return f"raw/{control}_1.fastq.gz"
#         elif  wildcards.run == "R2":
#                 return f"raw/{control}_2.fastq.gz"
#
#
# rule LinksControl:
#         input:
#                 linkFromControl
#         output:
#                 linkTo="links/{control}.control.{run}.fastq.gz"
#         message:
#                 "Executing Links rule from {input} to {output.linkTo}"
#         shell:
#                 """
#                 ln -s ../{input} {output.linkTo}
#                 """
