#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: quay.io/biocontainers/bwa:0.7.15--1

baseCommand: [bwa, mem, -K, "100000000", -Y, -p]
arguments:
  - position: 2
    valueFrom: $(inputs.fasta.dirname)/$(inputs.fasta.nameroot)
inputs:
  nthreads:
    type: int?
    default: 2
    inputBinding:
      position: 1
      prefix: -t
  fasta:
    type: File
    secondaryFiles:
      - $(inputs.amb)
      - $(inputs.ann)
      - $(inputs.bwt)
      - $(inputs.pac)
      - $(inputs.sa)
  amb:
    type: File
  ann:
    type: File
  bwt:
    type: File
  pac:
    type: File
  sa:
    type: File
  fastq1:
    type: File
    inputBinding:
      position: 3
  fastq2:
    type: File
    inputBinding:
      position: 4
  stderr_log_file_name:
    type: string

outputs:
  sam:
    type: stdout
  stderr_log:
    type: stderr
stdout: $(inputs.fastq1.nameroot).sam
stderr: $(inputs.stderr_log_file_name)
