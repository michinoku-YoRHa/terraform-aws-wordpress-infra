variable "ecs_sg_id" {
    type = string
}

variable "private_subnet_id" {
    type = list(string)
}

variable "tg_arn" {
    type = string
}

variable "listener_arn" {
    type = string
}

variable "db_endpoint" {
    type = string
}

variable "db_username" {
    type = string
}

variable "db_name" {
    type = string
}

variable "listener" {
  
}

variable "db_password_arn" {
    type = string
}

variable "efs_file_system_id" {
    type = string
}

variable "efs_access_point_id" {
    type = string
}

variable "s3_content_bucket_arn" {
    type = string
}