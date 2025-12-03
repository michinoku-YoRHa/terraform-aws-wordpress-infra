variable "vpc_cidr" {
    type = string
}

variable "azs" {
    type = list(string)
}

variable "private_subnet_cidrs" {
    type = map(string)
}