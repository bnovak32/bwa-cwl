cwlVersion: v1.2
class: CommandLineTool

label: bwa mem (0.7.17-139f68f)
doc: |
  Run BWA mem to align FASTQ files to a reference genome and sort the output
  by coordinate using samtools.

requirements:
  DockerRequirement:
    dockerPull: bnovak32/alpine-bwa:0.7.17-139f68f
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}

baseCommand: ["bwa","mem"]

arguments:
  - valueFrom: |
      ${ var cmd_line = "| samtools sort --write-index -o ";
         cmd_line += inputs.output_basename;
         cmd_line += ".bam##idx##" 
         cmd_line += inputs.output_basename;
         cmd_line += ".bai - ";
         return cmd_line; 
      }
    shellQuote: false
    position: 200

inputs:
  read1:
    label: Read1 FASTQ
    type: File
    format: 
      - edam:format_1930 # FASTQ (no quality score encoding specified)
      - edam:format_1931 # FASTQ-Illumina
      - edam:format_1932 # FASTQ-Sanger
      - edam:format_1933 # FASTQ-Solexa
    doc: FASTQ file containing reads to align.
    inputBinding:
      position: 101

  read2: 
    label: Read2 FASTQ
    type: File?
    format:
      - edam:format_1930 # FASTQ (no quality score encoding specified)
      - edam:format_1931 # FASTQ-Illumina
      - edam:format_1932 # FASTQ-Sanger
      - edam:format_1933 # FASTQ-Solexa
    doc: (Optional) read2 FASTQ file.
    inputBinding:
      position: 102

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
    inputBinding:
      position: 100

  output_sec_align:
    label: output all alignments?
    type: boolean?
    doc: Output all alignments for SE or unpaired PE reads. These alignments will be flagged as secondary.
    inputBinding:
      prefix: "-a"

  append_comments:
    label: append FASTA/Q comments?
    type: boolean?
    doc: Append FASTA/Q comments to SAM output. Can be used to transfer read meta data (such as barcodes) to the SAM output. Note that all comments after the first space in the read header line) must conform to the SAM spec. Malformed comments will lead to incorrectly formatted SAM output.
    inputBinding:
      prefix: "-C"

  assume_interleaved:
    label: Assume interleaved FASTQ input?
    type: boolean?
    doc: Assume the first input query file is interleaved FASTA/Q.
    inputBinding:
      prefix: "-p"

  output_basename:
    label: Output name
    type: string
    doc: Basename for output files

  threads:
    label: Num threads
    type: int?
    doc: (Optional) number of processing threads to use.
    inputBinding:
      prefix: "-t"

  read_group:
    label: Read group details
    type: 
      - type: record
        name: ReadGroupDetails
        fields:
          sample:
            type: string
            label: "Sample name (SM)"
          identifier:
            type: string
            label: "Read group identifier (ID)"
            doc: "This value must be unique among multiple samples in your experiment"
          platform:
            type:
              type: enum
              symbols: [ CAPILLARY, LS454, ILLUMINA, SOLID, HELICOS, IONTORRENT, PACBIO ]
            label: "Platform/technology used to produce the reads (PL)"
          library:
            type: string
            label: "Library name (LB)"
    inputBinding:
      shellQuote: false
      valueFrom: |
        ${ var rg_line = "-R '@RG\\tID:"+self.identifier;
           rg_line += "\\tSM:" + self.sample;
           rg_line += "\\tPL:" + self.platform;
           rg_line += "\\tLB:" + self.library + "'";
           return rg_line;
        }

outputs:
  aligned_reads:
    type: File
    format: edam:format_2572  # BAM
    secondaryFiles:
      - ^.bai
    outputBinding:
      glob: $(inputs.output_basename).bam
  bwa_log:
    type: File
    streamable: true
    outputBinding: 
      glob: $(inputs.output_basename).bwa.log

stderr: $(inputs.output_basename).bwa.log

$namespaces:
  edam: http://edamontology.org/
$schemas:
  - https://edamontology.org/EDAM_1.25.owl

