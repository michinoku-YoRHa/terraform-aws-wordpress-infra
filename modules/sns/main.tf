resource "aws_sns_topic" "topic" {
    name = "wordpress-topic"
}

resource "aws_sns_topic_subscription" "subscription" {
    topic_arn = aws_sns_topic.topic.arn
    protocol = "email"
    endpoint = var.sns_mail_address
}