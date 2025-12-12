data "aws_elb_service_account" "this" {}

resource "aws_s3_bucket" "log_bucket" {
    force_destroy = true
}

resource "aws_s3_bucket_policy" "alb_log_policy" {
    bucket = aws_s3_bucket.log_bucket.id

    policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSLoadBalancerLogging"
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.this.arn
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.log_bucket.arn}/*"
      }
    ]
  })    
}

resource "aws_s3_bucket" "content_bucket" {
    force_destroy = true
}