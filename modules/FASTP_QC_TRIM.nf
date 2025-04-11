/*
 * Quality control and trimming reads with fastp
 */

process FASTP_QC_TRIM {

    container 'community.wave.seqera.io/library/fastp:0.24.0--62c97b06e8447690'
    publishDir params.fastp_outdir, mode: 'copy'

    input:
        tuple path(read1), path(read2), val(base)
        val trim_front1
        val trim_front2
        val length_required
        val average_qual

     output:
        val(base), emit: base
        path "${base}_clean_R1.fastq.gz", emit: clean_R1
        path "${base}_clean_R2.fastq.gz", emit: clean_R2
        path "${base}_singletons.fastq.gz", emit: singletons
        path "${base}_fastp.html", emit: html
        path "${base}_fastp.json", emit: json
        path "${base}_stdout.log", emit: stdout
        path "${base}_stderr.log", emit: stderr

    script:

    """
    fastp -i $read1 -I $read2 -o ${base}_clean_R1.fastq.gz -O ${base}_clean_R2.fastq.gz \
    --unpaired1 ${base}_clean_R1_unpaired.fastq.gz --unpaired2 ${base}_clean_R2_unpaired.fastq.gz \
    --trim_front1 ${trim_front1} --trim_front2 ${trim_front2} \
    -l ${length_required} --average_qual ${average_qual} --trim_poly_x \
    -h ${base}_fastp.html \
    -j ${base}_fastp.json \
    > ${base}_stdout.log 2> ${base}_stderr.log
    cat ${base}_clean_R1_unpaired.fastq.gz ${base}_clean_R2_unpaired.fastq.gz > ${base}_singletons.fastq.gz

    """
}