resource "aws_cloudwatch_event_rule" "ecs_task_stopped" {
    name = "ecs-task-stopped"

    event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      clusterArn = [var.ecs_cluster_arn]
      lastStatus = ["STOPPED"]
    }
  })
}

resource "aws_cloudwatch_event_target" "target_sns" {
    rule = aws_cloudwatch_event_rule.ecs_task_stopped.name
    arn = var.sns_topic_arn
}