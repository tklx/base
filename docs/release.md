## build and test

```
export RELEASE=debian/jessie
builder/run chanko-upgrade
builder/run make clean
builder/run make all

docker build -t tklx/base:latest .
docker run -it --rm tklx/base:latest /bin/bash
```

## update changelog, readme and create signed tag

```
contrib/generate-changelog > CHANGELOG.tmp
mv CHANGELOG.tmp CHANGELOG.md
$EDITOR CHANGELOG.md # verify version is correct and tweak 
VERSION=$(head -1 CHANGELOG.md | awk '{print $2}')
OLD_VERSION=$(git tag -l |head -1)
sed -i "s/$OLD_VERSION/$VERSION/g" README.md
git add CHANGELOG.md README.md
git commit -m "updated for $VERSION release"
git tag -s -m "$VERSION release" $VERSION
```

## generate release files

```
mkdir releases/$VERSION
cp build/package.list releases/$VERSION/
cp build/rootfs.tar.xz releases/$VERSION/
gpg -u A16EB94D --armor --detach-sig releases/$VERSION/rootfs.tar.xz

ARCH=$(dpkg --print-architecture)
NAME=base-$VERSION-linux-$ARCH.aci
contrib/generate-aci-manifest tklx.org/base $VERSION $ARCH > build/manifest
cat build/manifest | python -m json.tool >/dev/null
sudo chown root:root build/manifest
sudo tar -C build --numeric-owner -Jcf releases/$VERSION/$NAME manifest rootfs
sudo rm build/manifest
sudo chown $USER:$USER releases/$VERSION/$NAME
gpg -u A16EB94D --armor --detach-sig releases/$VERSION/$NAME
```

## push to github

```
git push github
git push github --tags
```

## create new github release

- https://github.com/tklx/base/releases/new
- select $VERSION tag
- set description as $VERSION
- copy/paste entry from CHANGELOG.md and tweak
- add release files from releases/$VERSION/
- mark pre-release if relevant
- publish

## update docker hub

```
docker tag tklx/base:latest tklx/base:$VERSION
docker push tklx/base:$VERSION
```

- https://hub.docker.com/r/tklx/base/
- update description based on README.md

