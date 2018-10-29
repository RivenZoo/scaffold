.PHONY: all

all: frontend image

image:
	docker build -t PROJECT_NAME:latest .

frontend:
	cd DJANGO_PROJ_DIR/frontend && npm run build
