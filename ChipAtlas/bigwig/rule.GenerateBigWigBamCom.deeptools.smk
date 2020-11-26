
blacklistFile = config["hg19"]["blacklist"]



def getControl(wildcards):
        if wildcards.raw.find("merged") == -1:
                control = sampleDF.loc[sampleDF["Raw"] == wildcards.raw, "ControlName"].to_list()[0]
                return f"results/mapping/{control}.control.final.bam"
        else:
                return ""


def getParamsBamCom(wildcards):
        if wildcards.type == "None":
                return ""
        if wildcards.type == "SES":
                return "--scaleFactorsMethod SES -l 750"
        elif wildcards.type in ["RPKM", "BPM"]:
                return f"--scaleFactorsMethod None --normalizeUsing {wildcards.type}"




rule GenerateBigWigBamCom:
        input:
                bam="results/mapping/{raw}.final.bam",
                control=getControl
        output:
                BW="results/bigwig/{raw}.{type}.bigWig",

        threads:
                16
        message:
                "Executing GenerateBigWigBamCom rule for {wildcards.raw} with type of {wildcards.type}"
        params:
                getParamsBamCom
        shell:
                """
                bamCompare -b1 {input.bam} -b2 {input.control} -o {output.BW} \
                --extendReads 150 \
                --centerReads \
                -p {threads} \
                {params}
                """
