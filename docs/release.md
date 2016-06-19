## update changelog and create signed tag

```
contrib/generate-changelog > CHANGELOG.tmp
mv CHANGELOG.tmp CHANGELOG.md
$EDITOR CHANGELOG.md # verify version is correct and tweak 
VERSION=$(head -1 CHANGELOG.md | awk '{print $2}')
git add CHANGELOG.md
git commit -m "changelog: updated for $VERSION release"
git tag -s -m "$VERSION release" $VERSION
```

## generate release files

```
mkdir releases/$VERSION
cp build/package.list releases/$VERSION/
cp build/rootfs.tar.xz releases/$VERSION/
gpg -u A16EB94D --armor --detach-sig releases/$VERSION/rootfs.tar.xz
ln -sf $VERSION releases/latest
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

