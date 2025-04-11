/*
 * Assemble reads with SPADE
 */

process SPADES_ASSEMBLE {

    container 'community.wave.seqera.io/library/spades:4.1.0--77799c52e1d1054a'
    publishDir params.spades_outdir, mode: 'copy'

    input:
        val base
        path clean_R1
        path clean_R2 
        path singletons 
        val cov_cutoff
    
    output:
        val(base), emit: base
        path "${base}_spades", emit: outfolder
        path "${base}_stdout.log", emit: stdout
        path "${base}_stderr.log", emit: stderr

    script:
    """
    spades.py -1 ${clean_R1} -2 ${clean_R2} -s ${singletons} -o '${base}_spades' --isolate --cov-cutoff $cov_cutoff > ${base}_stdout.log 2> ${base}_stderr.log
    """
}