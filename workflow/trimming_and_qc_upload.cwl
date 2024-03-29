#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow
requirements:
  MultipleInputFeatureRequirement: {}
doc: Use fastq file as input and do trimming and quality check. Quality checks are done before trimming and after trimming.

inputs:
  fastq_url:
    type: string
    label: Download link of FastQ file from next generation sequencer
  nthreads:
    type: int?
    default: 2
    label: (optional) Number of cpu cores to be used
  aws_access_key_id:
    type: string
  aws_secret_access_key:
    type: string
  endpoint:
    type: string
    default: s3.amazonaws.com
  s3_bucket:
    type: string
  s3_upload_dir:
    type: string
    default: cwl_upload

steps:
  download_fastq:
    run: https://raw.githubusercontent.com/suecharo/test-workflow/master/tool/curl.cwl
    in:
      download_url: fastq_url
      downloaded_file_name:
        default: fastq.fq
      stderr_log_file_name:
        default: curl_fastq_stderr.log
    out:
      - downloaded_file
      - stderr_log
  qc_fastq:
    run: https://raw.githubusercontent.com/suecharo/test-workflow/master/tool/fastqc.cwl
    in:
      nthreads: nthreads
      fastq: download_fastq/downloaded_file
      stdout_log_file_name:
        default: fastqc_fastq_stdout.log
      stderr_log_file_name:
        default: fastqc_fastq_stderr.log
    out:
      - qc_result
      - stdout_log
      - stderr_log
  trimming:
    run: https://raw.githubusercontent.com/suecharo/test-workflow/master/tool/trimmomatic_se.cwl
    in:
      nthreads: nthreads
      fastq: download_fastq/downloaded_file
      stdout_log_file_name:
        default: trimmomatic_stdout.log
      stderr_log_file_name:
        default: trimmomatic_stderr.log
    out:
      - trimed_fastq
      - stdout_log
      - stderr_log
  qc_trimed_fastq:
    run: https://raw.githubusercontent.com/suecharo/test-workflow/master/tool/fastqc.cwl
    in:
      nthreads: nthreads
      fastq: trimming/trimed_fastq
      stdout_log_file_name:
        default: fastqc_trimed_fastq_stdout.log
      stderr_log_file_name:
        default: fastqc_trimed_fastq_stderr.log
    out:
      - qc_result
      - stdout_log
      - stderr_log
  s3_upload:
    run: https://raw.githubusercontent.com/suecharo/test-workflow/master/tool/s3_upload.cwl
    in:
      aws_access_key_id: aws_access_key_id
      aws_secret_access_key: aws_secret_access_key
      upload_file_list:
        source:
          - download_fastq/downloaded_file
          - download_fastq/stderr_log
          - qc_fastq/qc_result
          - qc_fastq/stdout_log
          - qc_fastq/stderr_log
          - trimming/trimed_fastq
          - trimming/stdout_log
          - trimming/stderr_log
          - qc_trimed_fastq/qc_result
          - qc_trimed_fastq/stdout_log
          - qc_trimed_fastq/stderr_log
      endpoint: endpoint
      s3_bucket: s3_bucket
      s3_upload_dir: s3_upload_dir
      upload_url_file_name:
        default: upload_url.txt
      stderr_log_file_name:
        default: s3_upload_stderr.log
    out:
      - upload_url

outputs:
  upload_url:
    type: File
    outputSource: s3_upload/upload_url
