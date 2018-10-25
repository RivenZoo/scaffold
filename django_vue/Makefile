.PHONY: all

all: front-dist image

image:
	docker build -t PROJECT_NAME:latest .

front-dist:
	cd DJANGO_PROJ_DIR/frontend && npm run build
