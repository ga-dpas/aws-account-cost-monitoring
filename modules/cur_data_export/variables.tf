variable "resource_prefix" {
  description = "Prefix used for all named resources, including S3 Bucket. Must be the same in destination and source stacks."
  type        = string
  default     = "acm"
}

variable "enable_scad" {
  description = "Whether to enable Split Cost Allocation Data (Scad). Set to 'false', if you experience performance issues due to dataset size."
  type        = bool
  default     = true
}

variable "time_granularity" {
  description = "Choose the time granularity for how you want the line items in the export to be aggregated. Valid values 'HOURLY', 'DAILY' or 'MONTHLY'. 'HOURLY' is a recommended option."
  type        = string
  default     = "HOURLY"
}

variable "file_compression_type" {
  description = "Choose the file compression type for the data export. Valid values 'GZIP' or 'PARQUET'."
  type        = string
  default     = "PARQUET"
}

variable "file_format" {
  description = "Choose the file format for the data export. Valid values 'TEXT_OR_CSV' or 'PARQUET'."
  type        = string
  default     = "PARQUET"
}

variable "s3_overwrite" {
  description = "Choose the option to overwrite the previous version or to create a new version in addition to the previous versions. Valid values 'CREATE_NEW_REPORT' or 'OVERWRITE_REPORT'."
  type        = string
  default     = "OVERWRITE_REPORT"
}

variable "data_export_bucket_name" {
  description = "AWS account specific S3 bucket name where DataExport will be stored. If not supplied then DataExport bucket expected to follow this naming convention - '<resource_prefix>-<account_id>-data-exports'. Review this doc for bucket configuration - https://docs.aws.amazon.com/cur/latest/userguide/dataexports-s3-bucket.html."
  default     = ""
  type        = string
}

variable "deploy_data_export_s3" {
  description = "Whether to deploy account specific S3 bucket where DataExport will be stored. If enabled, S3 bucket will be created in given account for supplied name - <var.data_export_bucket>. Set to 'false', if bucket already exists."
  default     = true
  type        = bool
}

variable "enable_s3_replication" {
  description = "Whether to enable DataExport S3 bucket replication configuration. If set to 'true', supply 'replication_data_export_bucket'."
  default     = true
  type        = bool
}

variable "data_exports_aggregate_bucket_name" {
  description = "S3 bucket name where DataExport will be replicated to (this can be your centralized S3 data aggregation bucket provisioned in monitoring account). Required if 'enable_s3_replication = true'."
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied"
  default     = {}
  type        = map(string)
}