# To start DB, PhpMyAdmin and the AR maps API locally:
# `make local-start`
# note: after you make any changes to the flask app, run this command again
# to redeploy
#
# To stop all running resources:
# `make local-clean`

docker-build:
	docker build -t armaps:latest .

local-clean:
	docker-compose \
		down \
		-v

local-start: docker-build
	docker-compose \
		-f ./docker-compose.yml \
		up \
		--detach

push-ecr: docker-build
	docker login -u AWS -p $(shell aws ecr get-login-password --profile=armaps) https://886571573136.dkr.ecr.us-east-1.amazonaws.com
	docker tag armaps:latest 886571573136.dkr.ecr.us-east-1.amazonaws.com/dev-armaps-ecr-repository:latest
	docker push 886571573136.dkr.ecr.us-east-1.amazonaws.com/dev-armaps-ecr-repository:latest
