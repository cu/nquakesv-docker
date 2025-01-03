FROM debian:12-slim as build
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /build

# Install prerequisites
RUN <<EOS sh -ex
    apt-get update
    apt-get install -y --no-install-recommends \
      apt-utils \
      ca-certificates \
      cmake \
      curl \
      gcc \
      git \
      libc6-dev \
      make meson \
      pkg-config
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    mkdir /out
EOS


# Build mvdsv
RUN <<EOS sh -ex
    git clone --depth 1 https://github.com/deurk/mvdsv.git
    cd mvdsv
    cmake -B build .
    cmake --build build
    mv build/mvdsv /out
    cd ..
    rm -rf mvdsv
EOS

# Build ktx
RUN <<EOS sh -ex
    git clone --depth 1 https://github.com/deurk/ktx.git
    cd ktx
    cmake -B build .
    cmake --build build
    mv build/qwprogs.so /out
    cd ..
    rm -rf ktx
EOS

FROM debian:12-slim as run
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /nquake

# Install prerequisites
RUN <<EOS sh -ex
    apt-get update
    apt-get install -y --no-install-recommends \
      ca-certificates \
      dnsutils \
      dos2unix \
      gettext \
      qstat \
      unzip \
      wget
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOS

# Copy files
COPY files .
COPY --from=build /out/mvdsv /nquake/mvdsv
COPY --from=build /out/qwprogs.so /nquake/ktx/qwprogs.so
COPY scripts/healthcheck.sh /healthcheck.sh
COPY scripts/entrypoint.sh /entrypoint.sh

# Cleanup
RUN <<EOS sh -ex
    find . -type f -print0 | xargs -0 dos2unix -q
    find . -type f -exec chmod -f 644 "{}" \;
    find . -type d -exec chmod -f 755 "{}" \;
    chmod +x mvdsv ktx/mvdfinish.qws ktx/qwprogs.so
EOS

VOLUME /nquake/logs
VOLUME /nquake/media
VOLUME /nquake/demos

ENTRYPOINT ["/entrypoint.sh"]
