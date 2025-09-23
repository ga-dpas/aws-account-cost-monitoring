data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

locals {
  dataexports_cur2 = {
    DefaultQuery = "SELECT bill_bill_type, bill_billing_entity, bill_billing_period_end_date, bill_billing_period_start_date, bill_invoice_id, bill_invoicing_entity, bill_payer_account_id, bill_payer_account_name, cost_category, discount, discount_bundled_discount, discount_total_discount, identity_line_item_id, identity_time_interval, line_item_availability_zone, line_item_blended_cost, line_item_blended_rate, line_item_currency_code, line_item_legal_entity, line_item_line_item_description, line_item_line_item_type, line_item_net_unblended_cost, line_item_net_unblended_rate, line_item_normalization_factor, line_item_normalized_usage_amount, line_item_operation, line_item_product_code, line_item_resource_id, line_item_tax_type, line_item_unblended_cost, line_item_unblended_rate, line_item_usage_account_id, line_item_usage_account_name, line_item_usage_amount, line_item_usage_end_date, line_item_usage_start_date, line_item_usage_type, pricing_currency, pricing_lease_contract_length, pricing_offering_class, pricing_public_on_demand_cost, pricing_public_on_demand_rate, pricing_purchase_option, pricing_rate_code, pricing_rate_id, pricing_term, pricing_unit, product, product_comment, product_fee_code, product_fee_description, product_from_location, product_from_location_type, product_from_region_code, product_instance_family, product_instance_type, product_instancesku, product_location, product_location_type, product_operation, product_pricing_unit, product_product_family, product_region_code, product_servicecode, product_sku, product_to_location, product_to_location_type, product_to_region_code, product_usagetype, reservation_amortized_upfront_cost_for_usage, reservation_amortized_upfront_fee_for_billing_period, reservation_availability_zone, reservation_effective_cost, reservation_end_time, reservation_modification_status, reservation_net_amortized_upfront_cost_for_usage, reservation_net_amortized_upfront_fee_for_billing_period, reservation_net_effective_cost, reservation_net_recurring_fee_for_usage, reservation_net_unused_amortized_upfront_fee_for_billing_period, reservation_net_unused_recurring_fee, reservation_net_upfront_value, reservation_normalized_units_per_reservation, reservation_number_of_reservations, reservation_recurring_fee_for_usage, reservation_reservation_a_r_n, reservation_start_time, reservation_subscription_id, reservation_total_reserved_normalized_units, reservation_total_reserved_units, reservation_units_per_reservation, reservation_unused_amortized_upfront_fee_for_billing_period, reservation_unused_normalized_unit_quantity, reservation_unused_quantity, reservation_unused_recurring_fee, reservation_upfront_value, resource_tags, savings_plan_amortized_upfront_commitment_for_billing_period, savings_plan_end_time, savings_plan_instance_type_family, savings_plan_net_amortized_upfront_commitment_for_billing_period, savings_plan_net_recurring_commitment_for_billing_period, savings_plan_net_savings_plan_effective_cost, savings_plan_offering_type, savings_plan_payment_option, savings_plan_purchase_term, savings_plan_recurring_commitment_for_billing_period, savings_plan_region, savings_plan_savings_plan_a_r_n, savings_plan_savings_plan_effective_cost, savings_plan_savings_plan_rate, savings_plan_start_time, savings_plan_total_commitment_to_date, savings_plan_used_commitment  FROM COST_AND_USAGE_REPORT"
    SCADQuery    = "SELECT bill_bill_type, bill_billing_entity, bill_billing_period_end_date, bill_billing_period_start_date, bill_invoice_id, bill_invoicing_entity, bill_payer_account_id, bill_payer_account_name, cost_category, discount, discount_bundled_discount, discount_total_discount, identity_line_item_id, identity_time_interval, line_item_availability_zone, line_item_blended_cost, line_item_blended_rate, line_item_currency_code, line_item_legal_entity, line_item_line_item_description, line_item_line_item_type, line_item_net_unblended_cost, line_item_net_unblended_rate, line_item_normalization_factor, line_item_normalized_usage_amount, line_item_operation, line_item_product_code, line_item_resource_id, line_item_tax_type, line_item_unblended_cost, line_item_unblended_rate, line_item_usage_account_id, line_item_usage_account_name, line_item_usage_amount, line_item_usage_end_date, line_item_usage_start_date, line_item_usage_type, pricing_currency, pricing_lease_contract_length, pricing_offering_class, pricing_public_on_demand_cost, pricing_public_on_demand_rate, pricing_purchase_option, pricing_rate_code, pricing_rate_id, pricing_term, pricing_unit, product, product_comment, product_fee_code, product_fee_description, product_from_location, product_from_location_type, product_from_region_code, product_instance_family, product_instance_type, product_instancesku, product_location, product_location_type, product_operation, product_pricing_unit, product_product_family, product_region_code, product_servicecode, product_sku, product_to_location, product_to_location_type, product_to_region_code, product_usagetype, reservation_amortized_upfront_cost_for_usage, reservation_amortized_upfront_fee_for_billing_period, reservation_availability_zone, reservation_effective_cost, reservation_end_time, reservation_modification_status, reservation_net_amortized_upfront_cost_for_usage, reservation_net_amortized_upfront_fee_for_billing_period, reservation_net_effective_cost, reservation_net_recurring_fee_for_usage, reservation_net_unused_amortized_upfront_fee_for_billing_period, reservation_net_unused_recurring_fee, reservation_net_upfront_value, reservation_normalized_units_per_reservation, reservation_number_of_reservations, reservation_recurring_fee_for_usage, reservation_reservation_a_r_n, reservation_start_time, reservation_subscription_id, reservation_total_reserved_normalized_units, reservation_total_reserved_units, reservation_units_per_reservation, reservation_unused_amortized_upfront_fee_for_billing_period, reservation_unused_normalized_unit_quantity, reservation_unused_quantity, reservation_unused_recurring_fee, reservation_upfront_value, resource_tags, savings_plan_amortized_upfront_commitment_for_billing_period, savings_plan_end_time, savings_plan_instance_type_family, savings_plan_net_amortized_upfront_commitment_for_billing_period, savings_plan_net_recurring_commitment_for_billing_period, savings_plan_net_savings_plan_effective_cost, savings_plan_offering_type, savings_plan_payment_option, savings_plan_purchase_term, savings_plan_recurring_commitment_for_billing_period, savings_plan_region, savings_plan_savings_plan_a_r_n, savings_plan_savings_plan_effective_cost, savings_plan_savings_plan_rate, savings_plan_start_time, savings_plan_total_commitment_to_date, savings_plan_used_commitment, split_line_item_actual_usage, split_line_item_net_split_cost, split_line_item_net_unused_cost, split_line_item_parent_resource_id, split_line_item_public_on_demand_split_cost, split_line_item_public_on_demand_unused_cost, split_line_item_reserved_usage, split_line_item_split_cost, split_line_item_split_usage, split_line_item_split_usage_ratio, split_line_item_unused_cost     FROM COST_AND_USAGE_REPORT"
  }

  account_id              = data.aws_caller_identity.current.account_id
  data_export_bucket_name = var.data_export_bucket_name != "" ? var.data_export_bucket_name : "${var.resource_prefix}-${local.account_id}-data-exports"
}

# --------------------------------------------------------
# S3 Bucket: To store cost & usage reports
# --------------------------------------------------------

data "aws_s3_bucket" "data_export_s3" {
  count  = var.deploy_data_export_s3 == false ? 1 : 0
  bucket = local.data_export_bucket_name
}

resource "aws_s3_bucket" "data_export_s3" {
  count  = var.deploy_data_export_s3 ? 1 : 0
  bucket = local.data_export_bucket_name

  force_destroy = false

  tags = merge(
    {
      Name = local.data_export_bucket_name
    },
    var.tags
  )

}

resource "aws_s3_bucket_server_side_encryption_configuration" "data_export_s3" {
  count  = var.deploy_data_export_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_s3[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data_export_s3" {
  count  = var.deploy_data_export_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_s3[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data_export_s3" {
  count  = var.deploy_data_export_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_s3[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "data_export_s3" {
  count  = var.deploy_data_export_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_s3[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "data_export_s3" {
  count  = var.deploy_data_export_s3 ? 1 : 0
  bucket = aws_s3_bucket.data_export_s3[0].id

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

resource "aws_s3_bucket_policy" "data_export_s3_policy" {
  count  = var.deploy_data_export_s3 ? 1 : 0
  bucket = local.data_export_bucket_name
  policy = jsonencode({
    Id      = "AllowBillingReadAndWrite"
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowTLS12Only"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}",
          "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}/*"
        ]
        Condition = {
          NumericLessThan = {
            "s3:TlsVersion" = 1.2
          }
        }
      },
      {
        Sid       = "AllowOnlyHTTPS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}",
          "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = false
          }
        }
      },
      {
        Sid    = "AllowBillingReadAndWrite"
        Effect = "Allow"
        Principal = {
          Service = "bcm-data-exports.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy",
          "s3:PutObject"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}",
          "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
    }
  )
}

# --------------------------------------------------------
# S3 Bucket Replication Configuration: For centralised report aggregation
# --------------------------------------------------------

resource "aws_iam_role" "data_export_replication_role" {
  count = var.enable_s3_replication ? 1 : 0
  name  = "${var.resource_prefix}-DataExportReplication"
  path  = "/${var.resource_prefix}/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "s3.amazonaws.com"
          ]
        }
        Action = [
          "sts:AssumeRole"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "data_export_replication_role_policy" {
  count = var.enable_s3_replication ? 1 : 0
  name  = "${var.resource_prefix}-DataExportReplication"
  role  = aws_iam_role.data_export_replication_role[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "arn:${data.aws_partition.current.partition}:s3:::${local.data_export_bucket_name}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = [
          "arn:${data.aws_partition.current.partition}:s3:::${var.data_exports_aggregate_bucket_name}/*/${local.account_id}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "data_export_s3_replication" {
  count  = var.enable_s3_replication ? 1 : 0
  bucket = var.deploy_data_export_s3 ? aws_s3_bucket.data_export_s3[0].id : local.data_export_bucket_name

  role = aws_iam_role.data_export_replication_role[0].arn

  rule {
    id       = "ReplicateCUR2Data"
    priority = 1

    filter {
      prefix = "cur2/${local.account_id}/${var.resource_prefix}-cur2/data/"
    }

    status = "Enabled"

    destination {
      bucket        = "arn:${data.aws_partition.current.partition}:s3:::${var.data_exports_aggregate_bucket_name}"
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Enabled"
    }
  }
}

# --------------------------------------------------------
# AWS Cost and Usage Report (CUR2) DataExport
# --------------------------------------------------------

resource "aws_bcmdataexports_export" "cur2_data_export" {
  provider = aws.data_exports
  export {
    name = "${var.resource_prefix}-cur2"
    data_query {
      query_statement = var.enable_scad ? local.dataexports_cur2["SCADQuery"] : local.dataexports_cur2["DefaultQuery"]
      table_configurations = {
        COST_AND_USAGE_REPORT = {
          BILLING_VIEW_ARN                      = "arn:${data.aws_partition.current.partition}:billing::${data.aws_caller_identity.current.account_id}:billingview/primary"
          TIME_GRANULARITY                      = var.time_granularity
          INCLUDE_RESOURCES                     = "TRUE"
          INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = "FALSE"
          INCLUDE_SPLIT_COST_ALLOCATION_DATA    = var.enable_scad ? "TRUE" : "FALSE"
        }
      }
    }
    description = "CUR 2.0 export"
    destination_configurations {
      s3_destination {
        s3_bucket = local.data_export_bucket_name
        s3_prefix = "cur2/${local.account_id}"
        s3_region = var.deploy_data_export_s3 ? aws_s3_bucket.data_export_s3[0].region : data.aws_s3_bucket.data_export_s3[0].region
        s3_output_configurations {
          overwrite   = var.s3_overwrite
          format      = var.file_format
          compression = var.file_compression_type
          output_type = "CUSTOM"
        }
      }
    }
    refresh_cadence {
      frequency = "SYNCHRONOUS"
    }
  }
}