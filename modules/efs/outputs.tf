output "aws_efs_file_system_id" {
    value = aws_efs_file_system.wordpress.id
}

output "aws_efs_access_point_id" {
    value = aws_efs_access_point.wordpress.id
}