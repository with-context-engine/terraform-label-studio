module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.identifier}-bucket"

  # https://labelstud.io/guide/persistent_storage#Configure-CORS-for-the-S3-bucket
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
      allowed_origins = ["*"]
      expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
      max_age_seconds = 3600
    }
  ]
}
