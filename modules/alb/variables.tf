variable "alb_sg_id" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "private_subnet_id" {
    type = list(string)
}

variable "public_subnet_id" {
    type = list(string)
}

variable "log_bucket_id" {
    type = string
}

variable "domain_name" {
    type = string 
}