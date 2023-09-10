ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}:-main"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-${BASE_IMAGE_NAME}-${IMAGE_FLAVOR}}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS framework
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

COPY system_files/shared /
COPY framework-install.sh /tmp/framework-install.sh
COPY framework-packages.json /tmp/framework-packages.json

# Run generic shared steps
RUN /tmp/framework-install.sh && \
    systemctl enable tlp && \
    systemctl enable fprintd && \
    systemctl enable rpm-ostree-countme && \
    rm -rf /tmp/* /var/* && \    
    ostree container commit && \
    mkdir -p /var/tmp && chmod -R 1777 /tmp /var/tmp

FROM framework AS silverblue
COPY system_files/shared/silverblue /

RUN systemctl enable dconf-update && \
    rm -rf /tmp/* /var/* && \
    ostree container commit

FROM framework AS kinoite
FROM framework AS vauxite
FROM framework AS sericea
FROM framework AS base
FROM framework AS lxqt
FROM framework AS mate
