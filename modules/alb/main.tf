data "aws_acm_certificate" "cert" {
    domain = var.domain_name
    statuses = ["ISSUED"]
    most_recent = true
}

resource "aws_lb" "alb" {
    load_balancer_type = "application"
    name = "wordpress"
    security_groups = [var.alb_sg_id]
    subnets = var.private_subnet_id
    internal = true

    access_logs {
      bucket = var.log_bucket_id
      prefix = "ALB"
      enabled = true
    }

    tags = {
      Name = "wordpress"
    }
}

resource "aws_lb_target_group" "tg" {
    name = "wordpress-tg"
    port = 443
    protocol = "HTTPS"
    vpc_id = var.vpc_id
}

resource "aws_lb_listener" "name" {
    load_balancer_arn = aws_lb.alb.arn
    port = "443"
    protocol = "HTTPS"
    certificate_arn = data.aws_acm_certificate.cert.arn
    
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
    }
}