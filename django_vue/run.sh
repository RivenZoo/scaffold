#!/usr/bin/env bash

docker stop PROJECT_NAME
docker rm PROJECT_NAME
docker run -d -p 8000:8000 --name PROJECT_NAME --env-file ~/.PROJECT_NAME PROJECT_NAME:latest
docker exec PROJECT_NAME crond -l 8