resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "my_subnet_private" {
  count = length(var.private_subnet_cidr)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]
}

resource "aws_subnet" "my_subnet_public" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = var.azs[count.index]
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count = length(var.public_subnet_cidr)
  route_table_id = aws_route_table.my_route_table.id
  subnet_id = element(aws_subnet.my_subnet_public[*].id, count.index)
}

resource "aws_security_group" "allow_tls" {
  name = "Allow TLS"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.my_vpc.id
  ingress {
    description = "Inbound HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description = "Inbound HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}