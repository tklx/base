# build docker image from rootfs (to be done automatically via ci)

## import release signing key if needed

```
GPGKEY=A16EB94D 
if ! gpg --list-keys $GPGKEY 2>&1 >/dev/null; then
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 0x$GPGKEY
fi
```

## download and verify latest release

```
VERSION=$(git tag -l | head -1)
GITHUB=https://github.com/tklx/base/releases/download/$VERSION
mkdir -p releases/$VERSION && cd releases/$VERSION
[ -e rootfs.tar.xz ] || wget $GITHUB/rootfs.tar.xz
[ -e rootfs.tar.xz.asc ] || wget $GITHUB/rootfs.tar.xz.asc
gpg --verify rootfs.tar.xz.asc
```

## build docker image and push to docker hub

```
echo -e 'FROM scratch\nADD rootfs.tar.xz /' > Dockerfile
echo -e '*\n!rootfs.tar.xz' > .dockerignore
docker build -t tklx/base:$VERSION .
docker run --rm tklx/base:$VERSION cat /etc/debian_version
docker push tklx/base:$VERSION
```

