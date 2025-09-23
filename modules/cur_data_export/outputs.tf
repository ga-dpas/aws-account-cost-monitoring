output "data_export_bucket_name" {
  value       = local.data_export_bucket_name
  description = "S3 bucket name for storing DataExports."
}

output "data_exports_aggregate_bucket_name" {
  value       = local.data_exports_aggregate_bucket_name
  description = "Centralized S3 bucket name for storing aggregate DataExports."
}
