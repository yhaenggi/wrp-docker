ARG ARCH
FROM ${ARCH}/ubuntu:bionic
MAINTAINER yhaenggi <yhaenggi-git-public@darkgamex.ch>

ARG ARCH
ENV ARCH=${ARCH}
ARG VERSION
ENV VERSION=${VERSION}

COPY ./qemu-x86_64-static /usr/bin/qemu-x86_64-static
COPY ./qemu-arm-static /usr/bin/qemu-arm-static
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64-static

WORKDIR /root/

# set noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install --no-install-recommends wget chromium-browser ca-certificates -y && apt-get clean && rm -Rf /var/cache/apt/ && rm -Rf /var/lib/apt/lists
# disable sandbox, no namespace in namespaces without privileged containers
COPY ./chromium-flags /etc/chromium-browser/default

RUN groupadd wrp -g 911
RUN useradd wrp -u 911 -g 911 -m -s /bin/bash

RUN mkdir /home/wrp/bin
WORKDIR /home/wrp

# ARCHES= amd64 arm32v7 arm64v8
# upstream arches= amd64 arm arm64
# set needed arch
RUN wget https://github.com/tenox7/wrp/releases/download/${VERSION}/wrp-$(echo $ARCH | sed 's/arm32v7/arm/; s/arm64v8/arm64/; s/amd64/amd64/')-linux -O bin/wrp && chmod +x bin/wrp

RUN rm /usr/bin/qemu-x86_64-static /usr/bin/qemu-arm-static /usr/bin/qemu-aarch64-static

USER wrp
EXPOSE 8080/tcp
ENTRYPOINT ["/home/wrp/bin/wrp"]
CMD ["-h", "-l", ":8080", "-t", "png"]
