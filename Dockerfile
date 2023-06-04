ARG app=winxuu

# create build stage
ARG TAG
FROM --platform=$BUILDPLATFORM golang:$TAG AS build
ARG app

# install dependencies
RUN apt-get update \
    && apt-get install -y \
        upx

# clone
RUN git clone https://github.com/chkpwd/$app /src/$app

# build and compress the binary
WORKDIR /src/$app
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    go build -ldflags "-s -w" -o $app \
    && upx --best --lzma $app \
    && chmod 500 $app

# set up final stage
FROM gcr.io/distroless/static:latest
ARG app

# run as nonroot
USER nonroot

# copy in binary
COPY --from=build --chown=nonroot:nonroot /src/$app/$app /$app

# listen on an unprivileged port
EXPOSE 3389

# run application
ENTRYPOINT ["/winxuu"]