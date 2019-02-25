FROM golang:1.11.5-alpine3.9

ENV GOPATH /go
ENV USER root
ENV CFSSL_COMMIT b94e044bb51ec8f5a7232c71b1ed05dbe4da96ce

WORKDIR /go/src/github.com/cloudflare

RUN set -x && \
    apk --no-cache add git curl gcc libc-dev && \
    git clone https://github.com/cloudflare/cfssl.git && \
    go get github.com/cloudflare/cfssl_trust/... && \
    go get github.com/GeertJohan/go.rice/rice && \
    cd cfssl && \
    git checkout $CFSSL_COMMIT && \
    rice embed-go -i=./cli/serve && \
    mkdir bin && cd bin && \
    go build ../cmd/cfssl && \
    go build ../cmd/cfssljson && \
    go build ../cmd/mkbundle && \
    go build ../cmd/multirootca && \
    echo "Build complete."

FROM alpine:3.9
COPY --from=0 /go/src/github.com/cloudflare/cfssl_trust /etc/cfssl
COPY --from=0 /go/src/github.com/cloudflare/cfssl/bin/ /usr/bin
