FROM ubuntu:16.04

MAINTAINER Nick Holbrook "nholbroo@umich.edu"

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev

COPY ./requirements.txt /armaps/requirements.txt

WORKDIR /armaps

RUN pip install -r requirements.txt

COPY . /armaps

# Uncomment for prod
#ENV POSTGRES_HOST=dev-armaps-database.cqrmtk2jubig.us-east-1.rds.amazonaws.com
#ENV POSTGRESQL_DATABASE_PASSWORD=

ENTRYPOINT FLASK_APP=armaps flask run --host 0.0.0.0 --port 8080
