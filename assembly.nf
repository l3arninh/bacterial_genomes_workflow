#!/usr/bin/env nextflow

/*
 * Pipeline parameters
 */
params.wd = '/Users/ninhle/Desktop/Academic/Spring2025/BIOL-7210/assignments/workflow/'
params.read_file = "read_data.txt"
params.fastp_outdir = "${params.wd}/fastp"
params.trim_front1 = 15
params.trim_front2 = 15
params.length_required = 50
params.average_qual = 30

params.spades_outdir = "${params.wd}/spades"
params.cov_cutoff = 10
params.genomics_scripts = "${params.wd}/genomics_scripts/"
params.filtered_dir = "${params.wd}/filtered_assemblies"

// Include modules
include { FASTP_QC_TRIM  } from './modules/FASTP_QC_TRIM.nf'
include { SPADES_ASSEMBLE } from './modules/SPADES_ASSEMBLE.nf'
include { FILTER_ASSEMBLY   } from './modules/FILTER_ASSEMBLY.nf'
include { PAIRWISE_FASTANI } from './modules/PAIRWISE_FASTANI.nf'

workflow {
    if ( !file(params.wd).exists() ) {
        file(params.wd).mkdirs()
    }

     paired_reads_ch = Channel.fromPath(params.read_file)
                            .splitCsv(sep: '\t', header: false)
                            .map { row ->
                                def r1 = file(row[0])
                                def r2 = file(row[1])
                                def sample = r1.getName().replaceFirst(/_1\.fastq(\.gz)?$/, '')
                                tuple(r1, r2, sample)
                            }

     FASTP_QC_TRIM (paired_reads_ch,params.trim_front1,params.trim_front2,params.length_required,params.average_qual)

     def genomics_scripts = file(params.genomics_scripts)
     if (!genomics_scripts.exists()) {
        "git clone https://github.com/chrisgulvik/genomics_scripts.git ${params.genomics_scripts}".execute().waitFor()
     }

     SPADES_ASSEMBLE (FASTP_QC_TRIM.out.base, 
                    FASTP_QC_TRIM.out.clean_R1, 
                    FASTP_QC_TRIM.out.clean_R2, 
                    FASTP_QC_TRIM.out.singletons,
                    params.cov_cutoff)
     
    FILTER_ASSEMBLY (params.genomics_scripts, SPADES_ASSEMBLE.out.base,
                    SPADES_ASSEMBLE.out.outfolder)
    
    filter_outputs_ch = FILTER_ASSEMBLY.out.collect()
    filtered_assemblies_ch =  filter_outputs_ch.map { file_list ->
                                                file_list.findAll { it.name.endsWith('filtered_assembly.fna') }
                                                }
    filtered_assemblies_list_ch = filtered_assemblies_ch.collect()

    PAIRWISE_FASTANI (filtered_assemblies_list_ch)
}
