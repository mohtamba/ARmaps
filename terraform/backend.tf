terraform {
  backend "s3" {
    bucket = "armaps-us-east-1-dev-terraform-backend"
    key    = "terraform/key"
    region = var.aws_region
  }
}