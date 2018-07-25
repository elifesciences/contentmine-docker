#!/bin/bash
set -e

source .env

docker push elifesciences/contentmine:${IMAGE_TAG}
docker tag elifesciences/contentmine:${IMAGE_TAG} elifesciences/contentmine:latest
docker push elifesciences/contentmine:latest
