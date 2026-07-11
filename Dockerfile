FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base
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
    # Dependencies
    KEPT_PACKAGES+=(chromium) && \
    KEPT_PACKAGES+=(chromium-driver) && \
    TEMP_PACKAGES+=(python3-dev) && \
    TEMP_PACKAGES+=(python3-pip) && \
    # python3-setuptools is required so pip can build legacy (setup.py)
    # sdists such as timeout-decorator; without it, the empty
    # /usr/lib/python3/dist-packages/setuptools namespace dir left behind by
    # python3-pkg-resources shadows the real package and breaks pip's
    # setup.py fallback (setuptools -> distutils, both unusable).
    TEMP_PACKAGES+=(python3-setuptools) && \
    KEPT_PACKAGES+=(python3-selenium) && \
    # Install packages
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "${KEPT_PACKAGES[@]}" \
        "${TEMP_PACKAGES[@]}" \
        && \
    # Install pip packages
    # --ignore-installed is required because apt-installed packages (e.g.
    # python3-typing-extensions pulled in by python3-selenium) have no pip
    # RECORD file, so pip cannot uninstall/upgrade them in place.
    python3 -m pip install --no-cache-dir --break-system-packages --ignore-installed -r /opt/app/requirements.txt && \
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
