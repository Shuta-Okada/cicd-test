FROM registry.access.redhat.com/ubi9-minimal:9.3-1612 AS base

ARG NODEJS_VERSION=18
ENV NODE_ENV production

RUN microdnf -y module disable nodejs && \
    microdnf -y module enable nodejs:$NODEJS_VERSION && \
    microdnf install -y --nodocs --setopt=install_weak_deps=0 nodejs && \
    microdnf install -y --nodocs --setopt=install_weak_deps=0 npm && \
    microdnf update -y tzdata && \
    microdnf reinstall -y --nodocs --setopt=install_weak_deps=0 tzdata && \
    microdnf -y clean all

RUN echo "ulimit: $(ulimit -n)"

WORKDIR /app
COPY ./ ./
RUN npm ci

