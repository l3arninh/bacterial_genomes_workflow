/*
 * Compute all pairwise ANI with FastANI 
 */

process PAIRWISE_FASTANI {

    // container "community.wave.seqera.io/library/fastani:1.33--4cb11e308108f42a"
    conda "fastani"
    publishDir params.wd, mode: 'copy'

    input:
        path filtered_assemblies

    output:
        path "fastani_pairwise.tsv"

    script:
    """
    
    shopt -s nullglob
    assemblies=(${filtered_assemblies})
    shopt -u nullglob


    for ((i = 0; i < \${#assemblies[@]}; i++)); do 
        for ((j = i + 1; j < \${#assemblies[@]}; j++)); do 
            echo "\${assemblies[i]} and \${assemblies[j]} being compared..."

            fastANI \\
              -q \${assemblies[i]} \\
              -r \${assemblies[j]} \\
              -o FastANI_\${assemblies[i]}_\${assemblies[j]}.tsv \\
              2> FastANI_\${assemblies[i]}_\${assemblies[j]}.stderr.log

            awk '{alignment_percent = \$4/\$5*100} {alignment_length = \$4*3000} {print \$0 "\\t" alignment_percent "\\t" alignment_length}' \\
              FastANI_\${assemblies[i]}_\${assemblies[j]}.tsv >> fastani_pairwise_noheader.tsv
        done
    done

    awk 'BEGIN {print "Query\\tReference\\t%ANI\\tNum_Fragments_Mapped\\tTotal_Query_Fragments\\t%Query_Aligned"} {print}' \\
      fastani_pairwise_noheader.tsv > fastani_pairwise.tsv
    """
}