variable "resource_prefix" {
  description = "Prefix used for all named resources, including S3 Bucket. Must be the same in destination and source stacks"
  type        = string
  default     = "acm"
}

variable "data_exports_aggregate_bucket_name" {
  description = "S3 bucket name where DataExport are aggregated to (this can be the same bucket if all installed in same account i.e. Source=Destination). If not supplied then bucket name expected to follow this naming convention - '<resource_prefix>-<account_id>-data-exports'. Review this doc for cross-account buckets replication - https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-walkthrough-2.html."
  default     = ""
  type        = string
}

variable "deploy_data_export_aggregate_s3" {
  description = "Whether to deploy S3 bucket where DataExports will be aggregated to. If enabled, S3 bucket will be created in given account for supplied name - <var.centralized_data_export_bucket>."
  default     = false
  type        = bool
}

variable "enable_s3_replication" {
  description = "Whether to enable S3 bucket policy configuration to support DataExports replication. If enabled, supply 'source_account_ids'."
  default     = false
  type        = bool
}

variable "source_account_ids" {
  description = "List of source account ids for bucket replication configuration Ex: ['12345678912', '98745612312',..]."
  default     = []
  type        = list(any)
}

variable "deploy_data_analytics" {
  description = "Whether to deploy AWS Glue and Athena for querying CUR2 data. Require for data analytics and monitoring using Grafana."
  default     = true
  type        = bool
}

variable "cur_crawler_schedule" {
  description = "A cron expression to initialize AWS Glue cur crawler. Refer doc for more detail - https://docs.aws.amazon.com/glue/latest/dg/monitor-data-warehouse-schedule.html."
  default     = "cron(0 2 * * ? *)"
  type        = string
}

# NOTE: The default value for cur_crawler_s3_path is set to support single account setup or
#   multi account with data replication so this needs to be revisited if your architecture varies.
#   cur_crawler_s3_path_default = var.enable_s3_replication ? "cur2/data/" : "cur2/${local.account_id}/${var.resource_prefix}-cur2/data/"
variable "cur_crawler_s3_path" {
  description = "The S3 path prefix that targets DataExports '../data/' folder for AWS Glue to crawl. If supplied this will override the default."
  default     = ""
  type        = string
}

variable "tags" {
  description = "Tags to be applied"
  type        = map(string)
}
