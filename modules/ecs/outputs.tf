output "ecs_cluster_name" {
    value = aws_ecs_cluster.wordpress.name
}

output "ecs_service_name" {
    value = aws_ecs_service.wordpress.name
}