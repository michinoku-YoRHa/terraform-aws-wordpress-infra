resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    tags = {
        Name = "web3-vpc"
    }
}

resource "aws_subnet" "private_subnet_1a" {
    vpc_id = aws_vpc.vpc.id
    availability_zone = "ap-northeast-1a"
    cidr_block = "${var.private_subnet_cidr_1a}"
    tags = {
        Name = "private-subnet-1a"
    }
}

resource "aws_route_table" "prvate_routetable" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "private-routetable"
    }
}