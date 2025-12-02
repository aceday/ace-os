ARG FEDORA_VERSION=43
ARG ARCH=x86_64

ARG OS_NAME=ace-os
ARG DEFAULT_TAG=latest

FROM ghcr.io/bazzite-org/kernel-bazzite:latest-f${FEDORA_VERSION}-${ARCH} AS kernel

FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora/fedora-bootc:${FEDORA_VERSION}
ARG DEFAULT_TAG=${DEFAULT_TAG}

# Base Image
# FROM ghcr.io/ublue-os/${BASE_IMAGE_NAME}-main:${FEDORA_VERSION}  AS base


## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest

# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

# RUN chmod +x /ctx/*.sh

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh && \
    /ctx/cleanup.sh

# 00-init
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/00-init.sh && \
    /ctx/cleanup.sh

# 01-kernel
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=bind,from=kernel,src=/,dst=/rpms/kernel \
    /ctx/01-kernel.sh && \
    /ctx/cleanup.sh


# 02-base
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/02-base.sh && \
    /ctx/cleanup.sh

# 03-de
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/03-de.sh && \
    /ctx/cleanup.sh

# 04-patch
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/04-patch.sh && \
#     /ctx/cleanup.sh

# 05-GNOME
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/05-dank.sh && \
#     /ctx/cleanup.sh

# 06-config
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/06-config.sh && \
    /ctx/cleanup.sh

# 07-initramfs
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/07-initramfs.sh && \
    /ctx/cleanup.sh

# 08-image-base
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    OS_NAME=${OS_NAME} DEFAULT_TAG=${DEFAULT_TAG} /ctx/08-image-base.sh && \
    /ctx/cleanup.sh

# 09-finalize
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/09-finalize.sh && \
    /ctx/cleanup.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
