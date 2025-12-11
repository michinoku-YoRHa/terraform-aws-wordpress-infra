variable "private_subnet_id" {
    type = list(string)
}

variable "aurora_sg_id" {
    type = string
}

variable "db_username" {
    type = string
}

variable "db_name" {
    type = string
}

variable "db_instance_class" {
    type = string
}

variable "maintenance_window" {
    type = string
}
