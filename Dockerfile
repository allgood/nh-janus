FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV JANUS_VERSION=v1.2.6

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    build-essential \
    autoconf \
    automake \
    libtool \
    pkg-config \
    cmake \
    meson \
    ninja-build \
    gengetopt \
    libmicrohttpd-dev \
    libjansson-dev \
    libssl-dev \
    libsrtp2-dev \
    libsofia-sip-ua-dev \
    libglib2.0-dev \
    libconfig-dev \
    libnice-dev \
    libcurl4-openssl-dev \
    libwebsockets-dev \
    libogg-dev \
    libopus-dev \
    libvorbis-dev \
    libvpx-dev \
    libx264-dev \
    libx265-dev \
    libaom-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    liblua5.3-dev \
    libusrsctp-dev \
    python3 \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth=1 --branch ${JANUS_VERSION} https://github.com/meetecho/janus-gateway.git /tmp/janus && \
    cd /tmp/janus && \
    sh autogen.sh && \
    ./configure \
      --prefix=/opt/janus \
      --disable-docs \
      --disable-rabbitmq \
      --disable-mqtt \
      --disable-nanomsg && \
    make -j"$(nproc)" && \
    make install && \
    make configs && \
    rm -rf /tmp/janus

COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8088 8089 8188 8989 10000-20000/udp

ENTRYPOINT ["/entrypoint.sh"]
