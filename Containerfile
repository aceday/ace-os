# Allow build scripts to be referenced without being copied into the final image

ARG FEDORA_VERSION=42
ARG KERNEL_VERSION=6.15.4-103.bazzite.fc42.x86_64 
ARG KERNEL_FLAVOR=bazzite
ARG BASE_IMAGE_NAME=silverblue

FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/${BASE_IMAGE_NAME}-main:${FEDORA_VERSION}  AS base

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
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

# 00-image-name
# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     /ctx/00-image-name.sh && \
#     ostree container commit

# 01-repos
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/01-repos.sh && \
    /ctx/cleanup.sh

# RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
#     --mount=type=cache,dst=/var/cache \
#     --mount=type=cache,dst=/var/log \
#     --mount=type=tmpfs,dst=/tmp \
#     --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
#     --mount=type=bind,from=akmods,src=/rpms,dst=/tmp/akmods-rpms \
#     /ctx/02-kernel.sh && \
#     /ctx/cleanup.sh


# 03-package
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/03-package.sh && \
    /ctx/cleanup.sh

# 04-patch
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/04-patch.sh && \
    /ctx/cleanup.sh

# 05-GNOME
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/05-gnome.sh && \
    /ctx/cleanup.sh

# 09-config
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/09-config.sh && \
    /ctx/cleanup.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint