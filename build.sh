#!/usr/bin/env bash
# build, tag, and push docker images

# exit if a command fails
set -o errexit
set -o nounset

# go docker image tag to use
tag="${TAG:-latest}"

# if no registry is provided, tag image as "local" registry
registry="${registry:-local}"

# set image name
image_name="winxuu"

# platforms to build for
platforms="linux/amd64"
platforms+=",linux/arm"
platforms+=",linux/arm64"

# copy native image to local image registry
docker buildx build \
                    --build-arg TAG="${tag}" \
                    -t "local/${image_name}:${image_version}" \
                    -t "local/${image_name}:latest" \
                    -f Dockerfile . \
                    --load

# push image to Hub registry
if [ "${push}" == "true" ]; then
    docker buildx build --platform "${platforms}" \
                        --build-arg TAG="${tag}" \
                        -t "${registry}/${image_name}:${image_version}" \
                        -t "${registry}/${image_name}:latest" \
                        -f Dockerfile . \
                        --push
fi