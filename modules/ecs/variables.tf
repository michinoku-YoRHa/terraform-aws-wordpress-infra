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

variable "db_password" {
    type = string
}

variable "db_name" {
    type = string
}

variable "listener" {
  
}