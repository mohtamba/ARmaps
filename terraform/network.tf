// VPC
resource "aws_vpc" "dev-armaps-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "dev-armaps-vpc"
  }
}

// Public Subnets
resource "aws_subnet" "dev-armaps-vpc-public-us-east-1a" {
  vpc_id              = aws_vpc.dev-armaps-vpc.id
  cidr_block          = "10.0.0.0/26"
  availability_zone   = "us-east-1a"

  tags = {
    Name = "dev-armaps-vpc-public-us-east-1a"
  }
}

resource "aws_subnet" "dev-armaps-vpc-public-us-east-1b" {
  vpc_id              = aws_vpc.dev-armaps-vpc.id
  cidr_block          = "10.0.0.64/26"
  availability_zone   = "us-east-1b"

  tags = {
    Name = "dev-armaps-vpc-public-us-east-1b"
  }
}

resource "aws_subnet" "dev-armaps-vpc-public-us-east-1c" {
  vpc_id              = aws_vpc.dev-armaps-vpc.id
  cidr_block          = "10.0.0.128/26"
  availability_zone   = "us-east-1c"

  tags = {
    Name = "dev-armaps-vpc-public-us-east-1c"
  }
}

// DB Subnets
resource "aws_subnet" "dev-armaps-vpc-db-us-east-1a" {
  vpc_id              = aws_vpc.dev-armaps-vpc.id
  cidr_block          = "10.0.1.0/26"
  availability_zone   = "us-east-1a"

  tags = {
    Name = "dev-armaps-vpc-db-us-east-1a"
  }
}

resource "aws_subnet" "dev-armaps-vpc-db-us-east-1b" {
  vpc_id              = aws_vpc.dev-armaps-vpc.id
  cidr_block          = "10.0.1.64/26"
  availability_zone   = "us-east-1b"

  tags = {
    Name = "dev-armaps-vpc-db-us-east-1b"
  }
}

resource "aws_subnet" "dev-armaps-vpc-db-us-east-1c" {
  vpc_id              = aws_vpc.dev-armaps-vpc.id
  cidr_block          = "10.0.1.128/26"
  availability_zone   = "us-east-1c"

  tags = {
    Name = "dev-armaps-vpc-db-us-east-1c"
  }
}

// IGW
resource "aws_internet_gateway" "dev-armaps-igw" {
  vpc_id = aws_vpc.dev-armaps-vpc.id

  tags = {
      Name = "dev-armaps-igw"
  }
}

// Route Table
resource "aws_route_table" "dev-armaps-rt-public" {
  vpc_id = aws_vpc.dev-armaps-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-armaps-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.dev-armaps-igw.id
  }

  tags = {
    Name = "dev-armaps-rt-public"
  }
}

// Route Table Associations
resource "aws_route_table_association" "dev-armaps-vpc-public-us-east-1a" {
  subnet_id      = aws_subnet.dev-armaps-vpc-public-us-east-1a.id
  route_table_id = aws_route_table.dev-armaps-rt-public.id
}

resource "aws_route_table_association" "dev-armaps-vpc-public-us-east-1b" {
  subnet_id      = aws_subnet.dev-armaps-vpc-public-us-east-1b.id
  route_table_id = aws_route_table.dev-armaps-rt-public.id
}

resource "aws_route_table_association" "dev-armaps-vpc-public-us-east-1c" {
  subnet_id      = aws_subnet.dev-armaps-vpc-public-us-east-1c.id
  route_table_id = aws_route_table.dev-armaps-rt-public.id
}

// Security Groups
resource "aws_security_group" "dev-armaps-public-sg" {
  name        = "dev-armaps-public-sg"
  description = "Public HTTP / HTTPS SG"
  vpc_id      = aws_vpc.dev-armaps-vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-armaps-vpc.cidr_block]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-armaps-vpc.cidr_block]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.dev-armaps-vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-armaps-public-sg"
  }
}