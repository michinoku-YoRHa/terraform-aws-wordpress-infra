output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "private_subnet" {
    value = values(aws_subnet.private)[*].id
}