resource "aws_db_subnet_group" "dev-armaps-database-subnet-group" {
  name       = "dev-armaps-database-subnet-group"
  subnet_ids = [
    aws_subnet.dev-armaps-vpc-db-us-east-1a.id,
    aws_subnet.dev-armaps-vpc-db-us-east-1b.id,
    aws_subnet.dev-armaps-vpc-db-us-east-1c.id
  ]

  tags = {
    Name = "dev-armaps-database-subnet-group"
  }
}

resource "aws_db_instance" "dev-armaps-database" {
  identifier = "dev-armaps-database"

  engine                      = "postgres"
  engine_version              = "13.1"
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false

//  storage_encrypted = true
  instance_class    = "db.t3.micro"

  allocated_storage = "20"
  storage_type      = "gp2"

  name     = var.database
  username = var.database_user
  password = var.database_password

  publicly_accessible    = true
  multi_az               = false
  availability_zone      = "us-east-1a"
  db_subnet_group_name   = aws_db_subnet_group.dev-armaps-database-subnet-group.name
  vpc_security_group_ids = [
    aws_security_group.dev-armaps-database-sg.id
  ]

//  timezone = "America/New_York"

  apply_immediately = true

  tags = {
    Name = "dev-armaps-database"
  }
}