FROM alpine:latest
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/community podman
RUN apk add --no-cache \
    python3 \
    py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    awscli \
    && rm -rf /var/cache/apk/*
ENV STORAGE_DRIVER=vfs