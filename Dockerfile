FROM golang:1.7-alpine

COPY . /go/src/github.com/sameo/clearcontainers-runtime-plugin
WORKDIR /go/src/github.com/sameo/clearcontainers-runtime-plugin

RUN set -ex \
    && apk add --no-cache --virtual .build-deps \
    gcc libc-dev \
    && go install --ldflags '-extldflags "-static"' \
    && apk del .build-deps

CMD ["/go/bin/clearcontainers-runtime-plugin"]
