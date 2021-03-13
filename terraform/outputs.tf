output "repo-url" {
  value = aws_ecr_repository.dev-armaps-ecr-repository.repository_url
}

output "bastion-host-ip" {
  value = aws_instance.dev-armaps-bastion-host.public_ip
}