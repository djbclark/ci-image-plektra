# CI image for Plektra jobs on SIPB Hyades (forgejo.mit.edu, libkrun runner): the
# cirruslabs Android SDK image plus JDK 17, node (so node actions such as
# actions/checkout run) and the loopback LD_PRELOAD shim for libkrun TSI.
# Shim source is pinned by commit, not copied here:
# https://github.com/djbclark/djbclark-ade/blob/master/skills/forgejo/examples/plektra/shim-by-default.md
FROM ghcr.io/cirruslabs/android-sdk:36

USER root
ARG SHIM_SHA=da6d68f
ARG SHIM_URL=https://raw.githubusercontent.com/djbclark/djbclark-ade/${SHIM_SHA}/skills/forgejo/examples/plektra/loopback-port-shim.c

RUN apt-get update -qq \
 && apt-get install -y -qq --no-install-recommends openjdk-17-jdk-headless nodejs curl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# gcc comes with the base image; the shim is built once here instead of in every job.
RUN curl -fsSL "$SHIM_URL" -o /tmp/portshim.c \
 && gcc -shared -fPIC -O2 -pthread -o /usr/local/lib/portshim.so /tmp/portshim.c -ldl \
 && rm /tmp/portshim.c

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}
# Opt-in: jobs set LD_PRELOAD=/usr/local/lib/portshim.so (or one line in /etc/ld.so.preload).
