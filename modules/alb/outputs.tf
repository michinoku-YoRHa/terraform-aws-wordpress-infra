output "tg_arn" {
    value = aws_lb_target_group.tg.arn
}

output "listner" {
    value = aws_lb_listener.https
}

output "listener_arn" {
    value = aws_lb_listener.https.arn
}

output "alb_dns_name" {
    value = aws_lb.alb.dns_name
}

output "alb_zone_id" {
    value = aws_lb.alb.zone_id
}