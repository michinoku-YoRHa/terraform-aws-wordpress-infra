resource "aws_lb" "alb" {
    load_balancer_type = "application"
    name = "wordpress"
    security_groups = [var.alb_sg_id]
    // subnetをvarで受け取るところから
}