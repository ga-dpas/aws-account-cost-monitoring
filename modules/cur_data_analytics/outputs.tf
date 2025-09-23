output "data_exports_aggregate_bucket_name" {
  value       = local.data_export_bucket_name
  description = "S3 bucket with aggregate Data Exports."
}

output "data_exports_glue_catalog_database_name" {
  value       = var.deploy_data_analytics ? aws_glue_catalog_database.data_export_db[0].name : ""
  description = "The AWS Glue catalog database for Data Exports."
}

output "data_exports_athena_workgroup_name" {
  value       = var.deploy_data_analytics ? aws_athena_workgroup.athena_workgroup[0].name : ""
  description = "The AWS Athena workgroup for Data Exports."
}

output "data_exports_athena_query_result_bucket_name" {
  value       = var.deploy_data_analytics ? aws_s3_bucket.athena_query_result_s3[0].id : ""
  description = "The AWS Athena workgroup query result bucket."
}

output "data_exports_read_access_policy_arn" {
  value       = var.deploy_data_analytics ? aws_iam_policy.data_exports_read_access_policy[0].arn : ""
  description = "Policy to allow read access to DataExports for querying using Athena. Attach it to Grafana role."
}
