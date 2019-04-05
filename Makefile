# Image URL to use all building/pushing image targets
IMG ?= quay.io/yeebase/nginx-php-fpm:dev

# Build the docker image
docker-build:
	docker build . -t ${IMG} -f Dockerfile

# Push the docker image
docker-push:
	docker push ${IMG}
