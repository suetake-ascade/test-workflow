#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  DockerRequirement:
    dockerPull: mesosphere/aws-cli
  EnvVarRequirement:
    envDef:
      - envName: AWS_ACCESS_KEY_ID
        envValue: $(inputs.aws_access_key_id)
      - envName: AWS_SECRET_ACCESS_KEY
        envValue: $(inputs.aws_secret_access_key)
  InitialWorkDirRequirement:
    listing: $(inputs.upload_file_list)
baseCommand: [s3, cp, --recursive]
arguments: [
  {valueFrom: "${return inputs.upload_file_list[0].dirname;}"},
  s3://$(inputs.s3_bucket)/$(inputs.s3_upload_dir_name)/,
]

inputs:
  aws_access_key_id:
    type: string
  aws_secret_access_key:
    type: string
  upload_file_list:
    type: File[]
  s3_bucket:
    type: string
  s3_upload_dir_name:
    type: string?
    default: sapporo_upload
  stdout_log_file_name:
    type: string
  stderr_log_file_name:
    type: string

outputs:
  stdout_log:
    type: stdout
  stderr_log:
    type: stderr
stdout: $(inputs.stdout_log_file_name)
stderr: $(inputs.stderr_log_file_name)
