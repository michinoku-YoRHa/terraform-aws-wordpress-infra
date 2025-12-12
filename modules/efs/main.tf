resource "aws_efs_file_system" "wordpress" {
    creation_token = "wordpress-efs"
    tags = {
      Name = "wordpress-efs"
    }
}

resource "aws_efs_mount_target" "wordpress" {
    file_system_id = aws_efs_file_system.wordpress.id
    subnet_id = var.private_subnet_id[0]
    security_groups = [var.efs_sg_id]
}

resource "aws_efs_access_point" "wordpress" {
    file_system_id = aws_efs_file_system.wordpress.id
    posix_user {
      uid = 33
      gid = 33
    }

    root_directory {
      path = "/wordpress-data"
      creation_info {
        owner_uid = 33
        owner_gid = 33
        permissions = "755"
      }
    }

    tags = {
      Name = "wordpress-efs-access-point"
    }
}