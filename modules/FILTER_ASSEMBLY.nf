/*
 * Filter contigs with script from https://github.com/chrisgulvik/genomics_scripts.git
 */

process FILTER_ASSEMBLY {
    publishDir params.filtered_dir, mode: 'copy'

    input:
        path genomics_scripts
        val base 
        path raw_assembly
    
    output:
        path "${base}*"
    
    script:
    """
    python2 ${genomics_scripts}/filter.contigs.py --infile ${raw_assembly}/contigs.fasta --outfile ${base}_filtered_assembly.fna --discarded ${base}_removed-contigs.fa > ${base}_contig-filtering.stdout.log 2> ${base}_contig-filtering.stderr.log

    """
}