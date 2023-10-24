cwlVersion: v1.2
class: Workflow

label: bwa 0.7.17-139f68f -- run BWA mem to align FASTQ files to a reference genome

requirements:
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement:
    expressionLib:
     - { $include: helper_functions.js }


inputs:
  read1array:
    label: Read1 FASTQ
    type: File[]
    format:
      - edam:format_1930 # FASTQ (no quality score encoding specified)
      - edam:format_1931 # FASTQ-Illumina
      - edam:format_1932 # FASTQ-Sanger
      - edam:format_1933 # FASTQ-Solexa
    doc: FASTQ file containing reads to align.

  read2array: 
    label: Read2 FASTQ
    type: File[]
    format:
      - edam:format_1930 # FASTQ (no quality score encoding specified)
      - edam:format_1931 # FASTQ-Illumina
      - edam:format_1932 # FASTQ-Sanger
      - edam:format_1933 # FASTQ-Solexa
    doc: Read2 FASTQ file.

  ref_genome:
    label: Genome FASTA 
    type: File
    secondaryFiles: 
      - .amb
      - .ann
      - .bwt
      - .pac
      - .sa
    doc: Reference genome sequence with BWA indices present side-by-side.

  output_sec_align:
    label: output all alignments?
    type: boolean?
    doc: Output all alignments for SE or unpaired PE reads. These alignments will be flagged as secondary.

  append_comments:
    label: append FASTA/Q comments?
    type: boolean?
    doc: Append FASTA/Q comments to SAM output. Can be used to transfer read meta data (such as barcodes) to the SAM output. Note that all comments after the first space in the read header line) must conform to the SAM spec. Malformed comments will lead to incorrectly formatted SAM output.

  threads:
    label: Num threads
    type: int?
    doc: (Optional) number of processing threads to use.

  platform:
    label: "Platform/technology used to produce the reads (PL)"
    type:
      type: enum
      symbols: [ CAPILLARY, LS454, ILLUMINA, SOLID, HELICOS, IONTORRENT, PACBIO ]

  sort_by_coord:
    label: Sort by coordinate
    default: false
    type: boolean

outputs:
  aligned_files:
    type: File[]
    secondaryFiles:
      - ^.bai?
    outputSource: 
      - bwa/aligned_reads
      - bwa_sorted/aligned_reads
    linkMerge: merge_flattened
    pickValue: all_non_null
  bwa_logs:
    type: File[]
    outputSource: 
      - bwa/bwa_log
      - bwa_sorted/bwa_log
    linkMerge: merge_flattened
    pickValue: all_non_null  

steps:
  bwa:
    run: bwamem.cwl
    scatter: [read1, read2]
    scatterMethod: dotproduct
    when: $(!inputs.sort_by_coord)
    in:
      read1: read1array
      read2: read2array
      threads: threads
      append_comments: append_comments
      ref_genome: ref_genome
      output_sec_align: output_sec_align
      output_basename: 
        valueFrom: ${ return generate_common_name(inputs.read1.basename, inputs.read2.basename); }
      sort_by_coord: sort_by_coord
      read_group:
        source: platform 
        valueFrom: |
          ${ return read_group_values(inputs.read1.basename, inputs.read_group); }
    out:
      - aligned_reads
      - bwa_log

  bwa_sorted:
    run: bwamem_with_sort.cwl
    scatter: [read1, read2]
    scatterMethod: dotproduct
    when: $(inputs.sort_by_coord)
    in:
      read1: read1array
      read2: read2array
      threads: threads
      append_comments: append_comments
      ref_genome: ref_genome
      output_sec_align: output_sec_align
      output_basename: 
        valueFrom: ${ return generate_common_name(inputs.read1.basename, inputs.read2.basename); }
      sort_by_coord: sort_by_coord
      read_group: 
        source: platform
        valueFrom: |
          ${ return read_group_values(inputs.read1.basename, inputs.read_group); }
    out:
      - aligned_reads
      - bwa_log
  
$namespaces:
  edam: http://edamontology.org/  
$schemas:
  - https://edamontology.org/EDAM_1.25.owl

