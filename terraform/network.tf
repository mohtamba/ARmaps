// VPC
resource "aws_vpc" "dev-armaps-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

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
    description = "Application"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "dev-armaps-database-sg" {
  name        = "dev-armaps-database-sg"
  description = "Postgres database SG"
  vpc_id      = aws_vpc.dev-armaps-vpc.id

  ingress {
    description = "Postgres"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev-armaps-database-sg"
  }
}

// Bastion Host
resource "aws_instance" "dev-armaps-bastion-host" {
  ami                    = "ami-0ff8a91507f77f867"
  subnet_id              = aws_subnet.dev-armaps-vpc-public-us-east-1a.id
  instance_type          = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.dev-armaps-public-sg.id
  ]
  ebs_optimized          = "false"
  source_dest_check      = "false"
  key_name               = "armaps-us-east-1"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }

  tags = {
    Name = "dev-armaps-bastion-host"
  }
}