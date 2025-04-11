/*
 * Genotype with MLST
 */

process MLST_GENOTYPE {

    container 'community.wave.seqera.io/library/mlst:2.23.0--b2fff78e301e42a8'
    publishDir params.wd, mode: 'copy'

    input:
        path filtered_assemblies

    output:
        path "MLST*"

    script:
    """
    mlst $filtered_assemblies > MLST_Summary.tsv 2> MLST.stderr.log
    """
}

