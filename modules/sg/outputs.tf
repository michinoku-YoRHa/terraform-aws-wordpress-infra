output "alb_sg_id" {
    value = aws_security_group.alb.id
}

output "ecs_sg_id" {
    value = aws_security_group.ecs.id
}

output "aurora_sg_id" {
    value = aws_security_group.aurora.id
}

output "efs_sg_id" {
    value = aws_security_group.efs.id
}