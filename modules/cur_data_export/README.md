# CUR Data Export

The Terraform module lets you deploy AWS Cost And Usage Report (CUR) 2.0 DataExports and related resources require for
data storage and replication such as DataExport S3 and replication configuration.

## Deployment

Deploy this TF module to all your Source Accounts as part of account Cost and Usage (CUR) monitoring solution.

### Pre-Requisite

- Permission to access AWS Cost & Usage Reports, AWS IAM and Amazon S3 in all Source Accounts.
- AWS Data Exports are available only in `us-east-1`, so carefully choose region for all other resources to avoid
cross region Amazon S3 costs.

> **Note**
>
> It can take up to 24 hours for AWS to start delivering exports to your Amazon S3 bucket. 
> Once delivery starts, AWS refreshes the billing and cost management export output at least once a day.

### Usage

```terraform
provider "aws" {
  alias  = "default"
  region = "ap-southeast-2"
  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1" # CUR is only available in us-east-1
  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "current" {}

locals {
  tags = {
    "cost_code"   = "xxxx"
    "project"     = "DPAS"
    "stack_name"  = "ACM"
    "environemnt" = "dev"
  }

  account_id                = data.aws_caller_identity.current.account_id
  data_aggregate_account_id = "123456789012"  # example
  resource_prefix           = "dpas-dev-acm"
  data_export_bucket        = "${local.resource_prefix}-${local.account_id}-data-exports" # local bucket
  data_exports_aggregate_bucket_name = "${local.resource_prefix}-${local.data_aggregate_account_id}-data-exports" # centralised bucket
}


module "cur2_data_export" {
  source = "git@github.com:ga-dpas/aws-account-cost-monitoring.git//module/cur_data_export?ref=main"

  resource_prefix       = local.resource_prefix

  deploy_data_export_s3   = true
  data_export_bucket_name = local.data_export_bucket


  # NOTE: Enable this for multi account cost monitoring setup.
  # Centralised replication bucket must exists in your data aggregation account.
  # Creation of replication bucket is supported in `module/cur_data_analytics` TF module.
  enable_s3_replication = false
  data_exports_aggregate_bucket_name = local.data_exports_aggregate_bucket_name
  
  providers = {
    aws.default = aws.default
    aws.data_exports = aws.us-east-1
  }

  tags = local.tags
}
```

### Inputs

| Name                               | Description                                                                                                                                                                                                                                                                                                                    | Default              | Required |
|------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------|----------|
| resource_prefix                    | Prefix used for all named resources, including S3 Bucket. Must be the same in destination and source stacks.                                                                                                                                                                                                                   | `"acm"`              | Yes      |
| enable_scad                        | Whether to enable Split Cost Allocation Data (Scad). Set to 'false', if you experience performance issues due to dataset size.                                                                                                                                                                                                 | `true`               | No       |
| time_granularity                   | Choose the time granularity for how you want the line items in the export to be aggregated. Valid values 'HOURLY', 'DAILY' or 'MONTHLY'. 'HOURLY' is a recommended option.                                                                                                                                                     | `"HOURLY"`           | No       |
| file_compression_type              | Choose the file compression type for the data export. Valid values 'GZIP' or 'PARQUET'.                                                                                                                                                                                                                                        | `"PARQUET"`          | No       |
| file_format                        | Choose the file format for the data export. Valid values 'TEXT_OR_CSV' or 'PARQUET'.                                                                                                                                                                                                                                           | `"PARQUET"`          | No       |
| s3_overwrite                       | Choose the option to overwrite the previous version or to create a new version in addition to the previous versions. Valid values 'CREATE_NEW_REPORT' or 'OVERWRITE_REPORT'.                                                                                                                                                   | `"OVERWRITE_REPORT"` | No       |
| data_export_bucket_name            | AWS account specific S3 bucket name where DataExport will be stored. If not supplied then DataExport bucket expected to follow this naming convention - '<resource_prefix>-<account_id>-data-exports'. Review this doc for bucket configuration - https://docs.aws.amazon.com/cur/latest/userguide/dataexports-s3-bucket.html. | `""`                 | Yes      |
| deploy_data_export_s3              | Whether to deploy account specific S3 bucket where DataExport will be stored. If enabled, S3 bucket will be created in given account for supplied name - <var.data_export_bucket>. Set to 'false', if bucket already exists.                                                                                                   | `true`               | Yes      |
| enable_s3_replication              | Whether to enable DataExport S3 bucket replication configuration. If set to 'true', supply 'replication_data_export_bucket'.                                                                                                                                                                                                   | `true`               | Yes      |
| data_exports_aggregate_bucket_name | S3 bucket name where DataExport will be replicated to (this can be your centralized S3 data aggregation bucket provisioned in monitoring account). Required if 'enable_s3_replication' is enabled.                                                                                                                             | `""`                 | Yes      |
| tags                               | Tags to be applied                                                                                                                                                                                                                                                                                                             | `{}`                 | Yes      |

### Outputs

| Name                               | Description                                                   |
|------------------------------------|---------------------------------------------------------------|
| data_export_bucket_name            | S3 bucket name for storing local DataExports.                 |
| data_exports_aggregate_bucket_name | Centralized S3 bucket name for storing aggregate DataExports. |
