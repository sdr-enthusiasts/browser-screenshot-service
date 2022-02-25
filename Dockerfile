FROM ghcr.io/sdr-enthusiasts/docker-baseimage:python
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
EXPOSE 5042

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY requirements.txt /opt/app/

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    # Required for building multiple packages
    TEMP_PACKAGES+=(build-essential) && \
    TEMP_PACKAGES+=(pkg-config) && \
    TEMP_PACKAGES+=(rustc) && \
    TEMP_PACKAGES+=(cargo) && \
    # Dependencies
    KEPT_PACKAGES+=(chromium-driver) && \
    KEPT_PACKAGES+=(chromium) && \
    TEMP_PACKAGES+=(libffi-dev) && \
    TEMP_PACKAGES+=(python3-dev) && \
    TEMP_PACKAGES+=(python3-pip) && \
    # Install packages
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "${KEPT_PACKAGES[@]}" \
        "${TEMP_PACKAGES[@]}" \
        && \
    # Upgrade pip
    python3 -m pip install --no-cache-dir --upgrade pip && \
    # Install pip packages
    python3 -m pip install --no-cache-dir -r /opt/app/requirements.txt && \
    # Clean-up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    # Simple date/time versioning (for now)
    date +%Y%m%d.%H%M > /CONTAINER_VERSION

COPY *.py /opt/app/

WORKDIR /opt/app/
CMD [ "/opt/app/snapapi.py" ]

#MAP_ARGS='zoom=11&hideSidebar&hideButtons&mapDim=0.3' BASE_URL='http://192.168.3.67:8078/' python3 snapapi.py
