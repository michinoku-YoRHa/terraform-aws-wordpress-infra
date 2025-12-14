resource "aws_cloudwatch_metric_alarm" "ecs_task_count" {
    alarm_name = "ecs-task-count"

    namespace = "AWS/ECS"
    metric_name = "RunningTaskCount"
    statistic = "Minimum"
    period = 60
    evaluation_periods = 1
    threshold = 1
    comparison_operator = "LessThanThreshold"
    treat_missing_data = "missing"

    dimensions = {
      ClusterName = var.ecs_cluster_name
      ServiceName = var.ecs_service_name
    }

    alarm_actions = [
        var.sns_topic_arn
    ]
}

locals {
    ecs_utilization_metrics = {
        cpu = {
            metric_name = "CPUUtilization"
            threshold = 80
        }
        memory = {
            metric_name = "MemoryUtilization"
            threshold = 80
        }
    }
}

resource "aws_cloudwatch_metric_alarm" "ecs_utilization" {
    for_each = local.ecs_utilization_metrics

    alarm_name = "ecs-${each.key}-utilization"

    namespace = "AWS/ECS"
    metric_name = each.value.metric_name
    statistic = "Average"
    period = 60
    evaluation_periods = 1
    threshold = each.value.threshold
    comparison_operator = "GreaterThanThreshold"
    treat_missing_data = "missing"

    dimensions = {
      ClusterName = var.ecs_cluster_name
      ServiceName = var.ecs_service_name
    }
}