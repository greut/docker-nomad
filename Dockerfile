FROM ubuntu:focal

SHELL ["/bin/bash", "-x", "-c", "-o", "pipefail"]

# Based on https://github.com/djenriquez/nomad
LABEL maintainer="Jonathan Ballet <jon@multani.info>"

# https://releases.hashicorp.com/nomad/
ENV NOMAD_VERSION=0.12.7 \
    GOSU_VERSION=1.10-1 \
    DUMB_INIT_VERSION=1.2.2-1.2

ARG DEBIAN_FRONTEND=noninteractive

ADD https://apt.releases.hashicorp.com/gpg hashicorp.gpg

# ca-certificates and tzdata will appear as "already installed", but it's only
# because of software-properties-common.

# hadolint ignore=DL3008
RUN apt-get update -qy \
 && apt-get install -qy --no-install-recommends \
        gnupg \
        software-properties-common \
 && apt-key add hashicorp.gpg \
 && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
 && apt-get update -qy \
 && apt-get install -qy --no-install-recommends \
        ca-certificates \
        dumb-init=${DUMB_INIT_VERSION} \
        gosu=${GOSU_VERSION} \
        nomad=${NOMAD_VERSION} \
        tzdata \
 && apt-get remove -qy --purge \
        gnupg \
        software-properties-common \
 && apt-get autoremove -qy \
 && rm -rf \
        hashicorp.gpg \
        /var/lib/apt/lists/*

# Expose the data directory as a volume since there's potentially long-running
# state in there
VOLUME /opt/nomad/data

EXPOSE 4646 4647 4648 4648/udp

COPY start.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/start.sh"]

CMD ["agent", "-dev"]
