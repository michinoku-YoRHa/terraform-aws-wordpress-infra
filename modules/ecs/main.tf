resource "aws_ecs_cluster" "wordpress" {
    name = "wordpress-cluster"

    setting {
      name = "containerInsights"
      value = "enabled"
    }
}

resource "aws_iam_role" "ecs_task_execution_role" {
    name = "ecs-task-execution-role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "ecs_secrests_read_policy" {
    name = "ecs-secrets-read-policy"

    policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "secretsmanager:GetSecretValue"
                ]
                Resource = var.db_password_arn
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_secrests_read_policy" {
    role = aws_iam_role.ecs_task_execution_role.name
    policy_arn = aws_iam_policy.ecs_secrests_read_policy.arn
}

resource "aws_iam_policy" "ecs_access_s3" {
    name = "ecs-access-s3-policy"

    policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = var.s3_content_bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ],
        Resource = "${var.s3_content_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs_task_role" {
    name = "ecs-task-role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_efs_policy" {
    role = aws_iam_role.ecs_task_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemClientReadWriteAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_task_access_s3_policy" {
    role = aws_iam_role.ecs_task_role.name
    policy_arn = aws_iam_policy.ecs_access_s3.arn
}

resource "aws_ecs_task_definition" "wordpress" {
    family = "wordpress"
    network_mode = "awsvpc"
    requires_compatibilities = ["FARGATE"]
    cpu = "512"
    memory = "1024"

    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
    task_role_arn = aws_iam_role.ecs_task_role.arn

    volume {
      name = "wordpress-efs"

      efs_volume_configuration {
        file_system_id = var.efs_file_system_id
        transit_encryption = "ENABLED"
        authorization_config {
          access_point_id = var.efs_access_point_id
          iam = "ENABLED"
        }
      }
    }

    container_definitions = jsonencode([
        {
            name = "wordpress"
            image = "wordpress:latest"
            essential = true
            portMappings = [
                {
                    containerPort = 80
                    hostPort = 80
                    protocol = "tcp"
                }
            ]
            environment = [
                { name = "WORDPRESS_DB_HOST",     value = var.db_endpoint },
                { name = "WORDPRESS_DB_USER",     value = var.db_username },
                { name = "WORDPRESS_DB_NAME",     value = var.db_name }
            ]
            secrets = [
                {
                name = "WORDPRESS_DB_PASSWORD"
                valueFrom = var.db_password_arn }
            ]
            mountPoints = [
                {
                    sourceVolume  = "wordpress-efs"
                    containerPath = "/var/www/html"
                    readOnly      = false
                }
            ]
        }
    ])
}

resource "aws_ecs_service" "wordpress" {
    name = "wordpress"
    cluster = aws_ecs_cluster.wordpress.id
    task_definition = aws_ecs_task_definition.wordpress.arn
    desired_count = 1
    launch_type = "FARGATE"

    network_configuration {
        subnets = [var.private_subnet_id[0]]
        security_groups = [var.ecs_sg_id]
        assign_public_ip = false
    }

    load_balancer {
      target_group_arn = var.tg_arn
      container_name = "wordpress"
      container_port = 80
    }

    depends_on = [var.listener]
}