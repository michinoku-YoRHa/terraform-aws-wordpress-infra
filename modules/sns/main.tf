resource "aws_sns_topic" "topic" {
    name = "wordpress-topic"
}

resource "aws_sns_topic_subscription" "subscription" {
    topic_arn = aws_sns_topic.topic.arn
    protocol = "email"
    endpoint = var.sns_mail_address
}

resource "aws_sns_topic_policy" "sns_from_eventbridge" {
    arn = aws_sns_topic.topic.arn

    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = "${aws_sns_topic.topic.arn}"
      }
    ]
  })
}