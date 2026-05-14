#!/usr/bin/env nextflow

// Module INCLUDE statements
include { SAMTOOLS_INDEX } from './modules/samtools_index.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk_haplotypecaller.nf'
include { GATK_JOINTGENOTYPING } from './modules/gatk_jointgenotyping.nf'

/*
 * Pipeline parameters
 */
params {
    // Primary input (array of three samples)
    input //: Path

    // Accessory files
    reference: Path
    reference_index: Path
    reference_dict: Path
    intervals: Path

    // Base name for final output file
    cohort_name: String

}

// Primary input

workflow {

    main:

    // Create input channel from a CSV file listing input BAM file paths
    reads_ch = channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> file(row.reads_bam) }

    // Load accessory files
    ref_file        = file(params.reference)
    ref_index_file  = file(params.reference_index)
    ref_dict_file   = file(params.reference_dict)
    intervals_file  = file(params.intervals)

    // Step 1: index each BAM file
    SAMTOOLS_INDEX(reads_ch)

    // Temporary diagnostics
    reads_ch.view()
    SAMTOOLS_INDEX.out.view()

    // Step 2: call variants per sample in GVCF mode
    GATK_HAPLOTYPECALLER(
        SAMTOOLS_INDEX.out,
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )

    // Step 3: collect all per-sample GVCFs and indexes
    all_gvcfs_ch = GATK_HAPLOTYPECALLER.out.vcf.collect()
    all_idxs_ch  = GATK_HAPLOTYPECALLER.out.idx.collect()

    // Step 4: joint genotype the cohort/family
    GATK_JOINTGENOTYPING(
        all_gvcfs_ch,
        all_idxs_ch,
        intervals_file,
        params.cohort_name,
        ref_file,
        ref_index_file,
        ref_dict_file
    )

    publish:

    // Declare outputs to publish
    bam_index = SAMTOOLS_INDEX.out
    gvcf = GATK_HAPLOTYPECALLER.out.vcf
    gvcf_idx = GATK_HAPLOTYPECALLER.out.idx
    joint_vcf = GATK_JOINTGENOTYPING.out.vcf
    joint_vcf_idx = GATK_JOINTGENOTYPING.out.idx
}

output {
    // Configure publish targets
    bam_index {
        path 'bam_index'
        mode 'copy'
    }
     gvcf {
        path 'gvcf'
        mode 'copy'
    }
    gvcf_idx {
        path 'gvcf'
        mode 'copy'
    }
    joint_vcf {
        path '.'
        mode 'copy'
    }
    joint_vcf_idx {
        path '.'
        mode 'copy'
    }
}
