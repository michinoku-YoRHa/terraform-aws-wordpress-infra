output "log_bucket" {
    value = aws_s3_bucket.log_bucket.id
}

output "content_bucket_arn" {
    value = aws_s3_bucket.content_bucket.arn
}