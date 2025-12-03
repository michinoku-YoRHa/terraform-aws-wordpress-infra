resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    tags = {
        Name = "web3-vpc"
    }
}

resource "aws_subnet" "private" {
    for_each = toset(var.azs)

    vpc_id = aws_vpc.vpc.id
    availability_zone = each.key
    cidr_block = var.private_subnet_cidrs[each.key]

    tags = {
      Name = "private-${each.key}"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
    tags = "public-routetable"
}


resource "aws_route_table" "prvate" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "private-routetable"
    }
}

resource "aws_route_table_association" "private" {
    for_each = aws_subnet.private_subnet

    subnet_id = each.value.id
    route_table_id = aws_route_table.prvate_routetable.id
}