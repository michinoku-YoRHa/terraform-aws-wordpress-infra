resource "aws_db_subnet_group" "subnet_group" {
    name = "wordpress"
    subnet_ids = var.private_subnet_id

    tags = {
      Name = "aurora-db-subnet-group"
    }
}

resource "aws_rds_cluster_parameter_group" "parameter_group" {
    name        = "aurora-mysql-wp"
    family      = "aurora-mysql8.0"

    parameter {
        name  = "slow_query_log"
        value = "1"
    }
    parameter {
        name  = "long_query_time"
        value = "1"
    }
    parameter {
        name  = "max_connections"
        value = "200"
    }
}

resource "random_password" "db_password" {
    length = 20
    special = false
}

resource "aws_secretsmanager_secret" "db_password" {
    name = "aurora-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
    secret_id = aws_secretsmanager_secret.db_password.id
    secret_string = random_password.db_password.result
}

resource "aws_rds_cluster" "wordpress" {
    cluster_identifier = "wordpress-aurora"
    engine = "aurora-mysql"
    engine_version = "8.0.mysql_aurora.3.08.2"
    db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.parameter_group.name
    master_username = var.db_username
    master_password = random_password.db_password.result
    database_name = var.db_name
    db_subnet_group_name = aws_db_subnet_group.subnet_group.name
    vpc_security_group_ids = [var.aurora_sg_id]
    storage_encrypted = true
    skip_final_snapshot = true
    backup_retention_period = 1
    preferred_maintenance_window = var.maintenance_window
}

resource "aws_rds_cluster_instance" "aurora_writer" {
    identifier = "wordpress-aurora-writer"
    cluster_identifier = aws_rds_cluster.wordpress.id
    instance_class = var.db_instance_class
    engine = aws_rds_cluster.wordpress.engine
    count = 1
}