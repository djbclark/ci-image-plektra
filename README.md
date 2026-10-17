# ci-image-plektra

## What this is

A public Linux/amd64 container image for Gradle, Android, and Robolectric jobs on SIPB's Hyades Forgejo CI runner. It layers JDK 17 and Node.js on `ghcr.io/cirruslabs/android-sdk:36`. The image also contains `/usr/local/lib/portshim.so`, a precompiled loopback shim for libkrun TSI behavior that can otherwise hang or flake Java networking tests. Baking it in avoids compiling and installing the shim in every job; enable it per job with `LD_PRELOAD`.

The shim source and investigation are maintained at [loopback-port-shim](https://forgejo.mit.edu/djbclark/loopback-port-shim). See its [`forgejo-ci` skill](https://forgejo.mit.edu/djbclark/loopback-port-shim/src/branch/main/skills/forgejo-ci/SKILL.md) for Hyades runner guidance and job setup.

## Who it is for

SIPB members running Gradle/Android builds on `forgejo.mit.edu`, especially jobs that need Android SDK 36, JDK 17, Node.js actions, or the loopback shim.

## Prerequisites

1. A Forgejo Actions workflow using SIPB Hyades (`runs-on: ubuntu`).
2. Access to pull the public image from `ghcr.io`.
3. The image's current digest, available in the GitHub Actions build summary.

## Install / Use

Use the image at the job container level and pin it by digest because Hyades runners do not automatically re-pull images. Keep `LD_PRELOAD` scoped to jobs that need the shim.

```yaml
jobs:
  android:
    runs-on: ubuntu
    container:
      image: ghcr.io/djbclark/ci-image-plektra@sha256:<digest>
    env:
      LD_PRELOAD: /usr/local/lib/portshim.so
    steps:
      - uses: https://github.com/actions/checkout@v4
      - run: ./gradlew testDebugUnitTest assembleDebug
```

For a job that does not need the shim, omit `LD_PRELOAD`. For the runner's disk layout, workflow details, and current digest lookup, follow the [`forgejo-ci` skill](https://forgejo.mit.edu/djbclark/loopback-port-shim/src/branch/main/skills/forgejo-ci/SKILL.md).

## Build your own variant

1. Fork or clone this repository and edit `Dockerfile` to add or remove packages.
2. Keep any shim source pinned to a reviewed commit; update `SHIM_SHA` when changing the source revision.
3. Build for `linux/amd64` and publish to a registry available to your Forgejo runner.
4. Pin the published image by digest in your workflow.

The GitHub Actions workflow in `.github/workflows/build.yml` builds and publishes this image to GHCR on pushes to `main` and on manual dispatch.

## Layout

1. `Dockerfile` — Android SDK base, JDK 17, Node.js, and pinned shim build.
2. `.github/workflows/build.yml` — GitHub Actions image build, publish, and verification.

## What is specific to djbclark

The `ghcr.io/djbclark/ci-image-plektra` package, pinned shim revision, and GitHub Actions publishing workflow are maintained by djbclark. Adapt the package/tag names, shim revision, and publishing credentials to your own registry and project.

## Status / known issues

The image targets linux/amd64. The shim is opt-in through `LD_PRELOAD`; it is not enabled globally by the image. This repository does not contain the shim source.

## Repositories

- Canonical: [forgejo.mit.edu/djbclark/ci-image-plektra](https://forgejo.mit.edu/djbclark/ci-image-plektra)
- Build mirror: [github.com/djbclark/ci-image-plektra](https://github.com/djbclark/ci-image-plektra), kept because GitHub Actions builds and publishes the GHCR image.

Push to Forgejo only: `git-forgejo -C ~/src/ci-image-plektra push origin main`. A Forgejo push mirror (SSH, on every commit and every 8 hours) copies it to GitHub, using a write deploy key that is limited to the GitHub repository. Check it with `forgejo-api GET /repos/djbclark/ci-image-plektra/push_mirrors` (`last_error` must be empty).

## Related

- [loopback-port-shim](https://forgejo.mit.edu/djbclark/loopback-port-shim) — shim source, documentation, and `forgejo-ci` skill.
- [djbclark/mit](https://forgejo.mit.edu/djbclark/mit) — index of djbclark's MIT projects.

## License

[MIT](LICENSE), copyright 2026 djbclark.
