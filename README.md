# ci-image-plektra

CI job image for Plektra on SIPB Hyades (forgejo.mit.edu): `ghcr.io/cirruslabs/android-sdk:36` plus JDK 17, node and a
precompiled loopback `LD_PRELOAD` shim (`/usr/local/lib/portshim.so`) that works around libkrun TSI bugs
(libkrun#818, #819, #860, #926, #929). The shim source and the investigation live in
[loopback-port-shim](https://forgejo.mit.edu/djbclark/loopback-port-shim); the Dockerfile pins the
shim by commit. Built for linux/amd64 by GitHub Actions. In a Forgejo workflow, pin by digest (images are never re-pulled):

    container:
      image: ghcr.io/djbclark/ci-image-plektra@sha256:<digest from the build summary>
    env:
      LD_PRELOAD: /usr/local/lib/portshim.so

Public image; it contains no private code.
