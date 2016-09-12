# tklx/base

A super slim root filesystem specifically designed to be used as a base
image for application [container][container] images.

Based on [Debian GNU/Linux][debian], the ``rootfs.tar.xz`` weighs in at
only 12MB, and has access to largest GNU/Linux software repository with
over [56,800 packages][debian_packages].

## Features

- Based on Debian GNU/Linux ([why debian?][why-debian]).
- Runtime agnostic (use with [Docker][docker], [CoreOS rkt][rkt], etc.).
- Built from scratch specifically for container usage.
- Smallest Debian based image as far as we know.
- Comfortable [interactive][bashrc] terminal (colorized, promptpath).
- Convenience [apt-clean][apt-clean] script to clean cache and optionally docs/locales.

## Usage (Docker)

```console
docker pull tklx/base:0.1.1
docker run -it tklx/base:0.1.1 /bin/bash
```

```dockerfile
FROM tklx/base:0.1.1
RUN apt-get update && apt-get -y install PACKAGES && apt-clean --aggressive
ENTRYPOINT ["something"]
```

## Usage (CoreOS rkt)

```console
rkt trust --prefix=tklx.org/base
rkt fetch tklx.org/base:0.1.1
rkt run tklx.org/base:0.1.1 --interactive --exec /bin/bash
```

```console
acbuild begin
acbuild set-name example.com/test
acbuild dep add tklx.org/base:0.1.1
acbuild run apt-get update && apt-get -y install PACKAGES && apt-clean --aggressive
acbuild set-exec something
acbuild write test-latest-linux-amd64.aci
acbuild end
```

## Status

Currently on major version zero (0.y.z). Per [Semantic Versioning][semver],
major version zero is for initial development, and should not be considered
stable. Anything may change at any time.

Release files are available [here][releases].

## Versioning

Releases are based on [Semantic Versioning][semver], and use the format
of ``MAJOR.MINOR.PATCH``. In a nutshell, the version will be incremented
based on the following:

- ``MAJOR``: incompatible and/or major changes, upgraded OS release
- ``MINOR``: backwards-compatible new features and functionality
- ``PATCH``: backwards-compatible bugfixes and package updates

## Issue Tracker

TKLX uses a central [issue tracker][tracker] on GitHub for reporting and
tracking of bugs, issues and feature requests.

## About

In case you're interested, TKLX is pronounced _/tickle-ex/_.

TKLX is a project by [TurnKey GNU/Linux][turnkeylinux]. TurnKey
GNU/Linux is a Debian based library of system images that pre-integrates
and polishes the best free software components into ready-to-use
solutions.

TurnKey was started in 2008 by [Alon Swartz][alonswartz] and [Liraz
Siri][lirazsiri] who were inspired by a belief in the power of free
software, like science, to promote the progress of a free & humane
society.

[container]: https://en.wikipedia.org/wiki/Operating-system-level_virtualization
[docker]: https://www.docker.com/
[appc]: https://github.com/appc/spec/
[rkt]: https://coreos.com/rkt/
[debian]: http://www.debian.org
[debian_packages]: https://packages.debian.org/stable/allpackages?format=txt.gz
[why-debian]: https://www.turnkeylinux.org/faq/why-debian
[bashrc]: https://github.com/tklx/base/blob/master/unit.d/bashrc/overlay/etc/skel/.bashrc
[apt-clean]: https://github.com/tklx/base/blob/master/unit.d/apt/overlay/usr/local/sbin/apt-clean
[semver]: http://semver.org/
[releases]: https://github.com/tklx/base/releases
[tracker]: https://github.com/tklx/tracker/issues
[turnkeylinux]: https://www.turnkeylinux.org
[alonswartz]: http://www.alonswartz.org
[lirazsiri]: http://www.liraz.org

