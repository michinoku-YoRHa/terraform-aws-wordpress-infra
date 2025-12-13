data "aws_elb_service_account" "this" {}

resource "random_string" "s3_suffix" {
    length = 20
    upper = false
    special = false
}

resource "aws_s3_bucket" "log_bucket" {
    bucket = "alb-log-bucket-${random_string.s3_suffix.id}"
    force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_log_policy" {
    bucket = aws_s3_bucket.log_bucket.id

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSLoadBalancerLoggingPut"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.this.arn
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.log_bucket.arn}/*"
      },
      {
        Sid    = "AWSLoadBalancerLoggingAcl"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.this.arn
        }
        Action = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.log_bucket.arn
      }
    ]
  })
}

resource "aws_s3_bucket" "content_bucket" {
    bucket = "content-bucket-${random_string.s3_suffix.id}"
    force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "content_bucket" {
    bucket = aws_s3_bucket.content_bucket.id

    rule {
      object_ownership = "BucketOwnerEnforced"
    }
}