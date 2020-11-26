

rule getFastaRule:
    input:
        "results/regions/{raw}.bed"
    output:
        "results/fasta/{raw}.fasta"
    shell:
        """
        bedtools getfasta -fi ~/genomeAnnotations/hg19.fa -bed {input} -tab > {output}
        """



cat results/regions/all.bed | awk -v s=500 '{{print $1, $2-s, $3+s, "peak."NR}}' | tr ' ' '\t' | head
