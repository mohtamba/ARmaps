us-east-1-dev:
	$(eval export AWS_PROFILE=armaps)
	$(eval export AWS_S3_BUCKET=armaps-us-east-1-dev-terraform-backend)
	$(eval export AWS_REGION=us-east-1)
	$(eval export ENV_NAME=dev)
	@true

terraform-clean:
	rm -rf \
		terraform.tfstate.d \
		.terraform/environment \
		.terraform/terraform.tfstate

init: terraform-clean
	terraform init \
		-backend-config="bucket=${AWS_S3_BUCKET}" \
		-backend-config="profile=${AWS_PROFILE}" \
		-backend-config="region=${AWS_REGION}"
	- terraform workspace new ${ENV_NAME}
	terraform workspace select ${ENV_NAME}

plan: init
	terraform plan \
		-var-file=./${AWS_REGION}/${ENV_NAME}/terraform.tfvars \
		-var-file=./${AWS_REGION}/${ENV_NAME}/secrets.tfvars \
		-var 'aws_profile=${AWS_PROFILE}' \
		-var 'aws_region=${AWS_REGION}'

apply: init
	terraform apply \
		-var-file=./${AWS_REGION}/${ENV_NAME}/terraform.tfvars \
		-var-file=./${AWS_REGION}/${ENV_NAME}/secrets.tfvars \
		-var 'aws_profile=${AWS_PROFILE}' \
		-var 'aws_region=${AWS_REGION}'