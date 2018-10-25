.PHONY: all

all: front-dist image

image:
	docker build -t PROJECT_NAME:latest .

front-dist:
	cd DJANGO_PROJECT_NAME/frontend && npm run build
