output "tg_arn" {
    value = aws_lb_target_group.tg.arn
}

output "listner" {
    value = aws_lb_listener.https
}

output "listener_arn" {
    value = aws_lb_listener.https.arn
}