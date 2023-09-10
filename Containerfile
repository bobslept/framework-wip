ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR}:-main"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-${BASE_IMAGE_NAME}-${IMAGE_FLAVOR}}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS framework
ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-silverblue}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

COPY system_files/shared /
COPY system_files/"${BASE_IMAGE_NAME}"? /

COPY framework-install.sh /tmp/framework-install.sh
COPY framework-packages.json /tmp/framework-packages.json

# Run specific sivlerblue steps
RUN if grep -q "silverblue" <<< "${BASE_IMAGE_NAME}"; then \
    systemctl enable dconf-update \
; fi

# Run generic shared steps
RUN /tmp/framework-install.sh && \
    systemctl enable tlp && \
    systemctl enable fprintd && \
    systemctl enable rpm-ostree-countme && \
    rm -rf /tmp/* /var/* && \    
    ostree container commit && \
    mkdir -p /var/tmp && chmod -R 1777 /tmp /var/tmp
