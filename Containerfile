ARG IMAGE_NAME=builder
ARG FEDORA_MAJOR_VERSION=41
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

ARG BUILDER_IMAGE="quay.io/fedora/fedora-minimal"
ARG BUILDER_IMAGE="${BUILDER_IMAGE}"

ARG BUILDER_BASE="${BUILDER_IMAGE}:${FEDORA_MAJOR_VERSION}"
FROM ${BUILDER_BASE} AS ${IMAGE_NAME}

# allow pinning to a specific release series (eg, 2.2.x or 2.3.x)
ARG ZFS_MINOR_VERSION="2.3"
ARG ZFS_MINOR_VERSION="${ZFS_MINOR_VERSION}"


COPY zfs-builder.sh /tmp/
RUN    /tmp/zfs-builder.sh

FROM scratch

# COPY --from=builder /var/cache/kernel-rpms /kernel-rpms
COPY --from=builder /var/cache/rpms /rpms
