FROM alpine:latest

# Install git
RUN apk add git

# Download helm
RUN wget https://get.helm.sh/helm-v3.6.0-linux-amd64.tar.gz

# Install helm
RUN tar -zxvf helm-v3.6.0-linux-amd64.tar.gz && \
    mv linux-amd64/helm /usr/local/bin/helm

# Copy entrypoint in the docker image
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint.sh executable
RUN chmod +x ./entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]
