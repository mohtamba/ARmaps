variable "aws_profile" {
  type          = string
  description   = "aws profile to use when deploying tf"
}

variable "aws_region" {
  type          = string
  description   = "aws region to deploy tf to"
  default       = "us-east-1"
}