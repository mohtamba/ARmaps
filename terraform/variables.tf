variable "aws_profile" {
  type          = string
  description   = "aws profile to use when deploying tf"
}

variable "aws_region" {
  type          = string
  description   = "aws region to deploy tf to"
  default       = "us-east-1"
}

variable "database" {
  type          = string
  description   = "database name"
  default       = "us-east-1"
}

variable "database_user" {
  type          = string
  description   = "database user"
  default       = "us-east-1"
}

variable "database_password" {
  type          = string
  description   = "database password"
  default       = "us-east-1"
}