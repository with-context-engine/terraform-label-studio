output "s3_bucket_arn" {
  description = "The object of the S3 bucket"
  value       = module.bucket.s3_bucket_arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.bucket.s3_bucket_id
}

output "rds_instance_arn" {
  description = "The ID of the RDS instance"
  value       = module.db.db_instance_arn
}

output "rds_instance_identifier" {
  description = "The endpoint of the RDS instance"
  value       = module.db.db_instance_identifier
}

output "rds_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = module.db.db_instance_endpoint
}

output "apprunner_service_arn" {
  description = "The ARN of the App Runner service"
  value       = aws_apprunner_service.label_studio.arn
}
