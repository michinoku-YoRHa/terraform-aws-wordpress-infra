output "db_endpoint" {
    value = aws_rds_cluster.wordpress.endpoint
}

output "db_password_arn" {
    value = aws_secretsmanager_secret_version.db_password.arn
}

output "db_writer_instance_id" {
    value = aws_rds_cluster_instance.aurora_writer.id
}