output "cloudwatch_alarm_cpu_arn" {
    value = aws_cloudwatch_metric_alarm.ecs_utilization["cpu"].arn
}

output "cloudwatch_alarm_memory_arn" {
    value = aws_cloudwatch_metric_alarm.ecs_utilization["memory"].arn
}