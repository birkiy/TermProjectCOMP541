



rule getRegionsRule:
    input:
        "results/peak/idr/{raw}.rep.summits.bed"
    output:
        "results/regions/{raw}.bed"
    threads:
        20
    shell:
        """
        cat {input} | awk -v s=500 '{{print $1, $2-s, $3+s, "peak."NR}}' | tr ' ' '\t' | \
        sort -k 1,1 -k 2,2n --parallel=10 - > {output}
        """


rule getAllRegionsRule:
    input:
        expand("results/regions/{raw}.bed", raw=sampleDF["Raw"])
    output:
        "results/regions/all.bed"
    threads:
        20
    shell:
        """
        cat {input} | sort -k 1,1 -k 2,2n --parallel=10 - | \
        bedtools merge -i - | \
        awk -v s=500 '{{mid=(int($2)+int($3))/2; printf("%s\t%d\t%d\n", $1, mid-s, mid+s, "union."NR);}}' | tr ' ' '\t' > {output}
        """



cat results/regions/22RV1.AR-C19.bed results/regions/22RV1.AR-C19.bed results/regions/22RV1.AR-V7.bed results/regions/22RV1.AR-V7.bed results/regions/22RV1.HOXB13.bed results/regions/22RV1.HOXB13.bed results/regions/LN95.AR-C19.bed results/regions/LN95.AR-C19.bed results/regions/LN95.AR-V7.bed results/regions/LN95.AR-V7.bed results/regions/LN95.HOXB13.bed results/regions/LN95.HOXB13.bed results/regions/LNCaP.dht.AR.bed results/regions/LNCaP.dht.AR.bed results/regions/LNCaP.veh.AR.bed results/regions/LNCaP.veh.AR.bed results/regions/malignant.1.AR.bed results/regions/malignant.1.AR.bed results/regions/malignant.2.AR.bed results/regions/malignant.2.AR.bed results/regions/malignant.3.AR.bed results/regions/malignant.3.AR.bed results/regions/malignant.4.AR.bed results/regions/malignant.4.AR.bed results/regions/non-malignant.1.AR.bed results/regions/non-malignant.1.AR.bed results/regions/non-malignant.2.AR.bed results/regions/non-malignant.2.AR.bed | sort -k 1,1 -k 2,2n --parallel=10 - | bedtools merge -i - | awk -v s=500 '{mid=(int($2)+int($3))/2;printf("%s\t%d\t%d\n", $1, mid-s, mid+s, "union."NR)}'  | \
            tr ' ' '\t' > results/regions/all.bed
