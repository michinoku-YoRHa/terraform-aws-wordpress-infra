# ecs監視設定
resource "aws_cloudwatch_metric_alarm" "ecs_task_count" {
    alarm_name = "ecs-task-count"

    namespace = "ContainerInsights"
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

# Aurora監視設定
locals {
    aurora_utilization_metrics = {
        cpu = {
            metric_name = "CPUUtilization"
            threshold = 80
        }
    }
}

resource "aws_cloudwatch_metric_alarm" "aurora_utilization" {
    for_each = local.aurora_utilization_metrics

    alarm_name = "aurora-${each.key}-utilization"
    namespace = "AWS/RDS"
    metric_name = each.value.metric_name
    statistic = "Average"
    period = 60
    evaluation_periods = 2
    threshold = each.value.threshold
    comparison_operator = "GreaterThanThreshold"
    treat_missing_data = "missing"

    dimensions = {
        DBInstanceIdentifier = var.db_writer_instance_id
    }
}

data "aws_cloudwatch_log_group" "rds_os_metrics" {
    name = "/aws/rds/instance/${var.aurora_writer_identifier}/osmetrics"
}

resource "aws_cloudwatch_log_metric_filter" "aurora_disk_used_percent" {
    name = "DiskUsedPercent"
    log_group_name = data.aws_cloudwatch_log_group.rds_os_metrics.name

    pattern = "{ ($.fileSys[0].mountPoint = \"/rdsdbdata\") }"

    metric_transformation {
    name      = "Custom-Disk_Used_Percent"
    namespace = "Aurora-Metrics"
    value     = "$.fileSys[0].usedPercent"

    dimensions = {
        DBInstanceIdentifier = "$.instanceID"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "aurora_disk_used_percent" {
    alarm_name = "aurora-disk-used-percent"
    metric_name = "Custom-Disk_Used_Percent"
    namespace = "Aurora-Metrics"
    dimensions = {
        DBInstanceIdentifier = var.aurora_writer_identifier
    }
    statistic = "Average"
    period = 60
    evaluation_periods = 2
    threshold = 80
    comparison_operator = "GreaterThanThreshold"
    treat_missing_data = "missing"
}

resource "aws_cloudwatch_log_metric_filter" "aurora_memory_total" {
    name = "MemoryTotal"
    log_group_name = data.aws_cloudwatch_log_group.rds_os_metrics.name

    pattern = "{ $.memory.total = * }"

    metric_transformation {
        name = "Custom-Memory_Total_Capacity"
        namespace = "Aurora-Metrics"
        value = "$.memory.total"

        dimensions = {
            DBInstanceIdentifier = "$.instanceID"
        }
    }
}

resource "aws_cloudwatch_metric_alarm" "aurora_memory_alarm" {
    alarm_name = "aurora-memory-used-percent"

metric_query {
    id = "total"
    metric {
      metric_name = "Custom-Mem_Total_Capacity"
      namespace   = "Aurora-Metrics"
      period      = 60
      stat        = "Average"
      dimensions = {
        DBInstanceIdentifier = var.aurora_writer_identifier
      }
    }
  }

  metric_query {
    id = "free"
    metric {
      metric_name = "FreeableMemory"
      namespace   = "AWS/RDS"
      period      = 60
      stat        = "Average"
      dimensions = {
        DBInstanceIdentifier = var.aurora_writer_identifier
      }
    }
  }

  metric_query {
    id          = "used_percent"
    expression  = "((total - (free / 1024)) / total) * 100"
    label       = "Custom-Memory_Total_Capacity"
    return_data = true
  }

    evaluation_periods = 2
    threshold = 80
    comparison_operator = "GreaterThanThreshold"
    treat_missing_data = "missing"
}