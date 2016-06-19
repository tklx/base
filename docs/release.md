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

## push to github and create new release

- git push github --tags

- create new release

    - use CHANGELOG.md as basis for release notes
    - upload files in releases/$VERSION

