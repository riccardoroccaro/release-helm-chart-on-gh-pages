FROM alpine:latest

# Install git
RUN apk add git

# Install helm
RUN tar -zxvf helm-v3.6.0-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm

ENTRYPOINT [ "entrypoint.sh" ]
