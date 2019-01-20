#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: alpine:latest

baseCommand: [echo]
arguments: [s3://$(inputs.s3_bucket)/$(inputs.s3_upload_dir_name)/]
inputs:
  s3_bucket:
    type: string
  s3_upload_dir_name:
    type: string
  file_name:
    type: string

outputs:
  s3_upload_url:
    type: stdout
stdout: $(inputs.file_name)
