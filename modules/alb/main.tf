data "aws_acm_certificate" "cert" {
    domain = var.domain_name
    statuses = ["ISSUED"]
    most_recent = true
}

resource "aws_lb" "alb" {
    load_balancer_type = "application"
    name = "wordpress"
    security_groups = [var.alb_sg_id]
    subnets = var.public_subnet_id
    internal = false

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
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc_id
    target_type = "ip"

    health_check {
        path                = "/wp-login.php"
        matcher             = "200-399"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 5
    }
}

resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.alb.arn
    port = "443"
    protocol = "HTTPS"
    certificate_arn = data.aws_acm_certificate.cert.arn
    
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
    }
}