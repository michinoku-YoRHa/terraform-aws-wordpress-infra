resource "aws_security_group" "alb" {
    name = "alb-sg"
    vpc_id = var.vpc_id
    tags = {
      Name = "alb-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https" {
    security_group_id = aws_security_group.alb.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 443
    to_port = 443
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all" {
    security_group_id = aws_security_group.alb.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}