FROM registry.access.redhat.com/ubi9-minimal:9.3-1612 AS base

ARG NODEJS_VERSION=18

RUN microdnf -y module disable nodejs && \
    microdnf -y module enable nodejs:$NODEJS_VERSION && \
    microdnf install -y --nodocs --setopt=install_weak_deps=0 nodejs && \
    microdnf update -y tzdata && \
    microdnf reinstall -y --nodocs --setopt=install_weak_deps=0 tzdata && \
    microdnf -y clean all

FROM base AS builder
RUN microdnf install -y --nodocs --setopt=install_weak_deps=0 npm
WORKDIR /app
COPY ./ ./
# RUN NODE_ENV=production && \
#     npm i && \
#     rm -rf stories && \
#     npm run build

RUN NODE_ENV=production
RUN npm i
RUN rm -rf stories
RUN npm run build


FROM base AS runner
ENV NODE_ENV production
WORKDIR /app
RUN chown -R 1001:0 /app && \
    chmod -R ug+rwx /app
COPY --from=builder /app/public ./public

USER 1001

ENV PORT 3000
EXPOSE 3000

CMD ["node", "server.js"]
