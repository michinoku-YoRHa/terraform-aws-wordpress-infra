resource "aws_security_group" "alb" {
    name = "alb-sg"
    vpc_id = var.vpc_id
    tags = {
      Name = "alb-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_https" {
    security_group_id = aws_security_group.alb.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_all" {
    security_group_id = aws_security_group.alb.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_security_group" "ecs" {
    name = "ecs-sg"
    vpc_id = var.vpc_id
    tags = {
      Name = "ecs-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
    security_group_id = aws_security_group.ecs.id
    referenced_security_group_id = aws_security_group.alb.id

    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_all" {
    security_group_id = aws_security_group.ecs.id

    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_security_group" "aurora" {
    name = "aurora-sg"
    vpc_id = var.vpc_id
    tags = {
      Name = "aurora-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "aurora_from_ecs" {
    security_group_id = aws_security_group.aurora.id
    referenced_security_group_id = aws_security_group.ecs.id

    from_port = 3306
    to_port = 3306
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "aurora_to_all" {
    security_group_id = aws_security_group.aurora.id

    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

resource "aws_security_group" "efs" {
    name = "efs-sg"
    vpc_id = var.vpc_id
    tags = {
      Name = "efs-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "efs_from_ecs" {
    security_group_id = aws_security_group.efs.id
    referenced_security_group_id = aws_security_group.ecs.id

    from_port = 2049
    to_port = 2049
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "efs_to_all" {
    security_group_id = aws_security_group.efs.id

    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}