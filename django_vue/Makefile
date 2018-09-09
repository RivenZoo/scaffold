.PHONY: all

all: frontend image

image:
	docker build -t PROJECT_NAME:latest .

frontend:
	cd DJANGO_PROJECT_NAME/frontend && npm run build
