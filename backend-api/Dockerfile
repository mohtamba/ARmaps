FROM ubuntu:16.04

MAINTAINER Nick Holbrook "nholbroo@umich.edu"

RUN apt-get update -y && \
    apt-get install -y python-pip python-dev

COPY ./requirements.txt /armaps/requirements.txt

WORKDIR /armaps

RUN pip install -r requirements.txt

COPY . /armaps

ENTRYPOINT FLASK_APP=armaps flask run --host 0.0.0.0 --port 5000