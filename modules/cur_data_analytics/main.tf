data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  data_export_bucket_name         = var.data_exports_aggregate_bucket_name != "" ? var.data_exports_aggregate_bucket_name : "${var.resource_prefix}-${local.account_id}-data-exports"
  athena_query_result_bucket_name = "${var.resource_prefix}-${local.account_id}-athena-output"

  cur2_crawler_s3_path_default = var.enable_s3_replication ? "cur2/" : "cur2/${local.account_id}/${var.resource_prefix}-cur2/data/"
  cur2_data_table_name         = var.enable_s3_replication ? "cur2" : "data"
  cur2_crawler_s3_path         = var.cur_crawler_s3_path != "" ? var.cur_crawler_s3_path : local.cur2_crawler_s3_path_default
}

# --------------------------------------------------------
# S3 Bucket: To aggregate DataExport CUR2 reports from all Source Accounts
# --------------------------------------------------------

resource "aws_s3_bucket" "data_export_aggregate_s3" {
  count  = var.deploy_data_export_aggregate_s3 ? 1 : 0
  bucket = local.data_export_bucket_name

  tags = merge(
    {
      Name = local.data_export_bucket_name
    },
    var.tags
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_export_aggregate_s3" {
  count  = var.deploy_data_export_aggregate_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_aggregate_s3[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data_export_aggregate_s3" {
  count  = var.deploy_data_export_aggregate_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_aggregate_s3[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data_export_aggregate_s3" {
  count  = var.deploy_data_export_aggregate_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_aggregate_s3[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "data_export_aggregate_s3" {
  count  = var.deploy_data_export_aggregate_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_aggregate_s3[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_export_aggregate_s3" {
  count  = var.deploy_data_export_aggregate_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_aggregate_s3[0].id

  rule {
    id     = "Object&Version Expiration"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
    expiration {
      days = 7
    }
  }

  rule {
    id     = "DeleteIncompleteMultipartUploadsAndExpiredDeleteMarkers"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
    expiration {
      expired_object_delete_marker = true
    }
  }
}

data "aws_iam_policy_document" "data_export_aggregate_s3_policy" {
  count = var.deploy_data_export_aggregate_s3 ? 1 : 0

  statement {
    sid     = "AllowTLS12Only"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.data_export_aggregate_s3[0].id}",
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.data_export_aggregate_s3[0].id}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }

  statement {
    sid     = "AllowOnlyHTTPS"
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.data_export_aggregate_s3[0].id}",
      "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.data_export_aggregate_s3[0].id}/*"
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_s3_replication ? [1] : []

    content {
      sid = "AllowReplicationWrite"
      actions = [
        "s3:ReplicateDelete",
        "s3:ReplicateObject"
      ]
      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.data_export_aggregate_s3[0].id}/*"
      ]

      principals {
        type        = "AWS"
        identifiers = distinct(concat(var.source_account_ids, [local.account_id]))
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_s3_replication ? [1] : []

    content {
      sid = "AllowReplicationRead"
      actions = [
        "s3:ListBucket",
        "s3:ListBucketVersions",
        "s3:GetBucketVersioning",
        "s3:PutBucketVersioning"
      ]
      resources = ["arn:${data.aws_partition.current.partition}:s3:::${aws_s3_bucket.data_export_aggregate_s3[0].id}"]

      principals {
        type        = "AWS"
        identifiers = distinct(concat(var.source_account_ids, [local.account_id]))
      }
    }
  }
}

resource "aws_s3_bucket_policy" "data_export_aggregate_s3_policy" {
  count  = var.deploy_data_export_aggregate_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_aggregate_s3[0].id
  policy = data.aws_iam_policy_document.data_export_aggregate_s3_policy[0].json
}

# ----------------------------------------------
# AWS Glue Catalog: Our database and tables
# ----------------------------------------------

resource "aws_glue_catalog_database" "data_export_db" {
  count       = var.deploy_data_analytics ? 1 : 0
  name        = "${var.resource_prefix}-data-export"
  catalog_id  = data.aws_caller_identity.current.account_id
  description = "Contains CUR2 DataExport results from the S3 bucket '${local.data_export_bucket_name}'"
  tags        = var.tags
}

resource "aws_glue_catalog_table" "cur2_data_table" {
  count         = var.deploy_data_analytics ? 1 : 0
  name          = local.cur2_data_table_name
  database_name = aws_glue_catalog_database.data_export_db[0].name
  owner         = "owner"
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    location          = "s3://${local.data_export_bucket_name}/${local.cur2_crawler_s3_path}"
    compressed        = false
    number_of_buckets = "-1"
    input_format      = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format     = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = 1
      }
    }
    columns {
      name = "bill_bill_type"
      type = "string"
    }
    columns {
      name = "bill_billing_entity"
      type = "string"
    }
    columns {
      name = "bill_billing_period_end_date"
      type = "timestamp"
    }
    columns {
      name = "bill_billing_period_start_date"
      type = "timestamp"
    }
    columns {
      name = "bill_invoice_id"
      type = "string"
    }
    columns {
      name = "bill_payer_account_id"
      type = "string"
    }
    columns {
      name = "bill_payer_account_name"
      type = "string"
    }
    columns {
      name = "cost_category"
      type = "map<string,string>"
    }
    columns {
      name = "discount"
      type = "map<string,double>"
    }
    columns {
      name = "identity_line_item_id"
      type = "string"
    }
    columns {
      name = "identity_time_interval"
      type = "string"
    }
    columns {
      name = "line_item_availability_zone"
      type = "string"
    }
    columns {
      name = "line_item_legal_entity"
      type = "string"
    }
    columns {
      name = "line_item_line_item_description"
      type = "string"
    }
    columns {
      name = "line_item_line_item_type"
      type = "string"
    }
    columns {
      name = "line_item_operation"
      type = "string"
    }
    columns {
      name = "line_item_product_code"
      type = "string"
    }
    columns {
      name = "line_item_resource_id"
      type = "string"
    }
    columns {
      name = "line_item_unblended_cost"
      type = "double"
    }
    columns {
      name = "line_item_usage_account_id"
      type = "string"
    }
    columns {
      name = "line_item_usage_account_name"
      type = "string"
    }
    columns {
      name = "line_item_usage_amount"
      type = "double"
    }
    columns {
      name = "line_item_usage_end_date"
      type = "timestamp"
    }
    columns {
      name = "line_item_usage_start_date"
      type = "timestamp"
    }
    columns {
      name = "line_item_usage_type"
      type = "string"
    }
    columns {
      name = "pricing_lease_contract_length"
      type = "string"
    }
    columns {
      name = "pricing_offering_class"
      type = "string"
    }
    columns {
      name = "pricing_public_on_demand_cost"
      type = "double"
    }
    columns {
      name = "pricing_purchase_option"
      type = "string"
    }
    columns {
      name = "pricing_term"
      type = "string"
    }
    columns {
      name = "pricing_unit"
      type = "string"
    }
    columns {
      name = "product"
      type = "map<string,string>"
    }
    columns {
      name = "product_from_location"
      type = "string"
    }
    columns {
      name = "product_instance_type"
      type = "string"
    }
    columns {
      name = "product_product_family"
      type = "string"
    }
    columns {
      name = "product_servicecode"
      type = "string"
    }
    columns {
      name = "product_to_location"
      type = "string"
    }
    columns {
      name = "reservation_amortized_upfront_fee_for_billing_period"
      type = "double"
    }
    columns {
      name = "reservation_effective_cost"
      type = "double"
    }
    columns {
      name = "reservation_end_time"
      type = "string"
    }
    columns {
      name = "reservation_reservation_a_r_n"
      type = "string"
    }
    columns {
      name = "reservation_start_time"
      type = "string"
    }
    columns {
      name = "reservation_unused_amortized_upfront_fee_for_billing_period"
      type = "double"
    }
    columns {
      name = "reservation_unused_recurring_fee"
      type = "double"
    }
    columns {
      name = "resource_tags"
      type = "map<string,string>"
    }
    columns {
      name = "savings_plan_amortized_upfront_commitment_for_billing_period"
      type = "double"
    }
    columns {
      name = "savings_plan_end_time"
      type = "string"
    }
    columns {
      name = "savings_plan_offering_type"
      type = "string"
    }
    columns {
      name = "savings_plan_payment_option"
      type = "string"
    }
    columns {
      name = "savings_plan_purchase_term"
      type = "string"
    }
    columns {
      name = "savings_plan_savings_plan_a_r_n"
      type = "string"
    }
    columns {
      name = "savings_plan_savings_plan_effective_cost"
      type = "double"
    }
    columns {
      name = "savings_plan_start_time"
      type = "string"
    }
    columns {
      name = "savings_plan_total_commitment_to_date"
      type = "double"
    }
    columns {
      name = "savings_plan_used_commitment"
      type = "double"
    }
    columns {
      name = "split_line_item_parent_resource_id"
      type = "string"
    }
    columns {
      name = "split_line_item_reserved_usage"
      type = "double"
    }
    columns {
      name = "split_line_item_actual_usage"
      type = "double"
    }
    columns {
      name = "split_line_item_split_usage"
      type = "double"
    }
    columns {
      name = "split_line_item_split_usage_ratio"
      type = "double"
    }
    columns {
      name = "split_line_item_split_cost"
      type = "double"
    }
    columns {
      name = "split_line_item_unused_cost"
      type = "double"
    }
    columns {
      name = "split_line_item_net_split_cost"
      type = "double"
    }
    columns {
      name = "split_line_item_net_unused_cost"
      type = "double"
    }
    columns {
      name = "split_line_item_public_on_demand_split_cost"
      type = "double"
    }
    columns {
      name = "split_line_item_public_on_demand_unused_cost"
      type = "double"
    }

  }

  parameters = {
    "classification"     = "parquet"
    "compressionType"    = "none"
    "UPDATED_BY_CRAWLER" = aws_glue_crawler.cur2_crawler[0].name
  }

  lifecycle {
    ignore_changes = [
      storage_descriptor["columns"],
      partition_keys,
      parameters,
    ]
  }

}

# --------------------------------------------------------
# AWS Glue Crawler: To crawl the DataExport CUR2 reports
# --------------------------------------------------------
resource "aws_iam_role" "data_export_crawler_role" {
  count = var.deploy_data_analytics ? 1 : 0
  name  = "${var.resource_prefix}-DataExportCrawler"
  path  = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "glue.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "data_export_crawler_policy" {
  count = var.deploy_data_analytics ? 1 : 0
  name  = "${var.resource_prefix}-DataExportCrawler"
  role  = aws_iam_role.data_export_crawler_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:UpdateDatabase",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:GetTable",
          "glue:GetTables",
          "glue:BatchCreatePartition",
          "glue:CreatePartition",
          "glue:DeletePartition",
          "glue:BatchDeletePartition",
          "glue:UpdatePartition",
          "glue:GetPartition",
          "glue:GetPartitions",
          "glue:BatchGetPartition",
          "glue:ImportCatalogToGlue"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${local.account_id}:catalog",
          "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${local.account_id}:database/${aws_glue_catalog_database.data_export_db[0].name}",
          "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${local.account_id}:table/${aws_glue_catalog_database.data_export_db[0].name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${local.account_id}:log-group:/aws-glue/crawlers:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.name}:${local.account_id}:log-group:/aws-glue/crawlers:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_glue_crawler" "cur2_crawler" {
  count         = var.deploy_data_analytics ? 1 : 0
  name          = "${var.resource_prefix}-DataExportCUR2Crawler"
  description   = "A recurring crawler that keeps your CUR table in Athena up-to-date."
  database_name = aws_glue_catalog_database.data_export_db[0].name
  role          = aws_iam_role.data_export_crawler_role[0].arn

  s3_target {
    path = "s3://${local.data_export_bucket_name}/${local.cur2_crawler_s3_path}"
    exclusions = [
      "**.json",
      "**.yml",
      "**.sql",
      "**.csv",
      "**.csv.metadata",
      "**.gz",
      "**.zip",
      "**/cost_and_usage_data_status/*",
      "aws-programmatic-access-test-object"
    ]
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  recrawl_policy {
    recrawl_behavior = "CRAWL_EVERYTHING"
  }

  # NOTE: crawler is initialised based on schedule defined
  # If required we can switch to use lambda that can trigger crawler
  # upon the arrival of new files in an data-export S3 bucket
  schedule = var.cur_crawler_schedule

  configuration = jsonencode({
    "Version" : 1.0,
    "Grouping" : {
      "TableGroupingPolicy" : "CombineCompatibleSchemas"
    },
    "CrawlerOutput" : {
      "Tables" : {
        "AddOrUpdateBehavior" : "MergeNewColumns"
      }
    }
  })
}

# --------------------------------------------------------
# Athena Workgroup and Output Bucket: For Grafana Dashboards & Visualization
# --------------------------------------------------------

resource "aws_s3_bucket" "athena_query_result_s3" {
  count         = var.deploy_data_analytics ? 1 : 0
  bucket        = local.athena_query_result_bucket_name
  force_destroy = true

  tags = merge(
    {
      Name = local.athena_query_result_bucket_name
    },
    var.tags
  )
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena_query_result_s3" {
  count  = var.deploy_data_analytics ? 1 : 0
  bucket = aws_s3_bucket.athena_query_result_s3[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena_query_result_s3" {
  count  = var.deploy_data_analytics ? 1 : 0
  bucket = aws_s3_bucket.athena_query_result_s3[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "athena_query_result_s3" {
  count  = var.deploy_data_analytics ? 1 : 0
  bucket = aws_s3_bucket.athena_query_result_s3[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "athena_query_result_s3" {
  count  = var.deploy_data_analytics ? 1 : 0
  bucket = aws_s3_bucket.athena_query_result_s3[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "athena_query_result_s3" {
  count  = var.deploy_data_analytics ? 1 : 0
  bucket = aws_s3_bucket.athena_query_result_s3[0].id

  rule {
    id     = "Object&Version Expiration"
    status = "Enabled"
    filter {}
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
    expiration {
      days = 30
    }
  }
}

resource "aws_athena_workgroup" "athena_workgroup" {
  count         = var.deploy_data_analytics ? 1 : 0
  name          = "${var.resource_prefix}-athena-workgroup"
  description   = "Athena Workgroup utilized to group grafana dashboard query executions"
  state         = "ENABLED"
  force_destroy = true
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration {
      output_location = "s3://${local.athena_query_result_bucket_name}/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
      acl_configuration {
        s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
      }
    }
  }

  tags = var.tags
}

resource "aws_iam_policy" "data_exports_read_access_policy" {
  count       = var.deploy_data_analytics ? 1 : 0
  name        = "${var.resource_prefix}-data-exports-read-access"
  description = "Policy for Grafana to allow DataExports read access"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "athena:GetQueryExecution",
            "athena:GetQueryResults",
            "athena:GetQueryResultsStream",
            "athena:GetWorkGroup",
            "athena:StartQueryExecution",
            "athena:StopQueryExecution"
          ],
          "Resource" : [
            "*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "glue:GetDatabase",
            "glue:GetTable",
            "glue:GetTables",
            "glue:GetPartition",
            "glue:GetPartitions",
            "glue:BatchGetPartition"
          ],
          "Resource" : [
            "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${local.account_id}:catalog",
            "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${local.account_id}:database/${aws_glue_catalog_database.data_export_db[0].name}",
            "arn:${data.aws_partition.current.partition}:glue:${data.aws_region.current.name}:${local.account_id}:table/${aws_glue_catalog_database.data_export_db[0].name}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
            "s3:CreateBucket",
            "s3:PutObject",
            "s3:PutBucketPublicAccessBlock"
          ],
          "Resource" : [
            "arn:${data.aws_partition.current.partition}:s3:::${local.athena_query_result_bucket_name}",
            "arn:${data.aws_partition.current.partition}:s3:::${local.athena_query_result_bucket_name}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:ListBucket"
          ],
          "Resource" : [
            "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:GetObjectVersion"
          ],
          "Resource" : [
            "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}/*"
          ]
        }
      ]
    }
  )
}
