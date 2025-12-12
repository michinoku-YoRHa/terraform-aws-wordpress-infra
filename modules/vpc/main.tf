resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    tags = {
        Name = "web3-vpc"
    }

    enable_dns_hostnames = true
    enable_dns_support = true
}

// private subnet
resource "aws_subnet" "private" {
    for_each = toset(var.azs)

    vpc_id = aws_vpc.vpc.id
    availability_zone = each.key
    cidr_block = var.private_subnet_cidrs[each.key]

    tags = {
      Name = "private-${each.key}"
    }
}

resource "aws_route_table" "prvate" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "private-routetable"
    }
}

resource "aws_route_table_association" "private" {
    for_each = aws_subnet.private

    subnet_id = each.value.id
    route_table_id = aws_route_table.prvate.id
}

// publicsubnet
resource "aws_subnet" "public" {
    for_each = toset(var.azs)

    vpc_id = aws_vpc.vpc.id
    availability_zone = each.key
    cidr_block = var.public_subnet_cidrs[each.key]

    tags = {
      Name = "public-${each.key}"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "internet-gateway"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "public-routetable"
    }
}

resource "aws_route" "igw" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public

    subnet_id = each.value.id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat_eip" {
    domain = "vpc"

}

resource "aws_nat_gateway" "nat_gw" {
    subnet_id = aws_subnet.public[var.azs[0]].id
    allocation_id = aws_eip.nat_eip.id
    tags = {
      Name = "nat-gateway"
    }
}

resource "aws_route" "nat" {
    route_table_id = aws_route_table.prvate.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
}
