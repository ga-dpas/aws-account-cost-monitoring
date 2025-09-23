# CUR Data Export

The Terraform module lets you deploy DataExports aggregation and analytics solution to your
Centralized Monitoring Account (CMA), enabling data analysis and visualization.

## Deployment

Deploy this TF module to your Data Collection Account (or Centralized Monitoring Account) as part of account Cost and Usage (CUR) monitoring solution.

### Pre-Requisite

- In each account, permission to access AWS Cost & Usage Reports, AWS IAM and Amazon S3.

> **Note**
>
> After you set up data export to create a report, it can take up to `24 hours` for AWS to deliver the first report to
> your Amazon S3 bucket.

### Usage

```terraform
provider "aws" {
  alias  = "default"
  region = "ap-southeast-2"
  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  tags = {
    "stack_name"  = "ACM"
    "project"     = "DPAS"
    "cost_code"   = "xxxx"
    "environemnt" = "dev"
  }

  account_id      = data.aws_caller_identity.current.account_id
  resource_prefix = "acm-dpas"
  data_export_bucket = "${local.resource_prefix}-${local.account_id}-data-exports" # centralised bucket
}


module "cur2_data_analytics" {
  source = "git@github.com:ga-dpas/aws-account-cost-monitoring.git//module/cur_data_analytics?ref=main"

  resource_prefix = local.resource_prefix
  
  # Data aggregation configuration
  data_exports_aggregate_bucket_name = local.data_export_bucket
  # Enable this for account cost monitoring S3 replication configuration
  deploy_data_export_aggregate_s3 = false
  enable_s3_replication           = false
  source_account_ids              = ["123456789012", "98745612312"] # example
  
  # Data analytics configuration
  deploy_data_analytics = true

  tags = local.tags
}
```

### Inputs

| Name                            | Description                                                                                                                                                                                                                                                                                                                                                                                                         | Default               | Required |
|---------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|----------|
| resource_prefix                 | Prefix used for all named resources, including S3 Bucket. Must be the same in destination and source stacks.                                                                                                                                                                                                                                                                                                        | `"acm"`               | Yes      |
| centralized_data_export_bucket  | S3 bucket name where DataExport are aggregated to (this can be the same bucket if all installed in same account i.e. Source=Destination). If not supplied then bucket name expected to follow this naming convention - '<resource_prefix>-<account_id>-data-exports'. Review this doc for cross-account buckets replication - https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-walkthrough-2.html. | `""`                  | Yes      |
| deploy_data_export_aggregate_s3 | Whether to deploy S3 bucket where DataExports will be aggregated to. If enabled, S3 bucket will be created in given account for supplied name - <var.centralized_data_export_bucket>.                                                                                                                                                                                                                               | `false`               | Yes      |
| enable_s3_replication           | Whether to enable S3 bucket policy configuration to support DataExports replication. If enabled, supply 'source_account_ids'.                                                                                                                                                                                                                                                                                       | `false`               | Yes      |
| source_account_ids              | List of source account ids for bucket replication configuration Ex: ['123456789012', '98745612312',..].                                                                                                                                                                                                                                                                                                             | `[]`                  | Yes      |
| deploy_data_analytics           | Whether to deploy AWS Glue and Athena for querying CUR2 data. Require for data analytics and monitoring using Grafana.                                                                                                                                                                                                                                                                                              | `true`                | No       |
| cur_crawler_schedule            | A cron expression to initialize AWS Glue CUR2 crawler. Refer doc for more detail - https://docs.aws.amazon.com/glue/latest/dg/monitor-data-warehouse-schedule.html.                                                                                                                                                                                                                                                 | `"cron(0 2 * * ? *)"` | No       |
| cur_crawler_s3_path             | The S3 path prefix that targets DataExports 'data' folder for AWS Glue to crawl. If supplied this will override the default.                                                                                                                                                                                                                                                                                        | `""`                  | No       |
| tags                            | Tags to be applied                                                                                                                                                                                                                                                                                                                                                                                                  | `{}`                  | No       |

### Outputs

| Name                                         | Description                                                                                      |
|----------------------------------------------|--------------------------------------------------------------------------------------------------|
| data_exports_aggregate_bucket_name           | S3 bucket with aggregate Data Exports.                                                           |
| data_exports_glue_catalog_database_name      | The AWS Glue catalog database for Data Exports.                                                  |
| data_exports_athena_workgroup_name           | The AWS Athena workgroup for Data Exports.                                                       |
| data_exports_athena_query_result_bucket_name | The AWS Athena workgroup query result bucket.                                                    |
| data_exports_read_access_policy_arn          | Policy to allow read access to DataExports for querying using Athena. Attach it to Grafana role. |
