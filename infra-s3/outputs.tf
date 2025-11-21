output "bucket_name" {
  description = "Navnet på S3-bucketen for analyseresultater"
  value       = local.bucket_name
}

output "bucket_region" {
  description = "Region for S3-bucketen"
  value       = var.aws_region
}

output "lifecycle_rule_id" {
  description = "ID på lifecycle-regelen"
  value       = aws_s3_bucket_lifecycle_configuration.analysis.rule[0].id
}