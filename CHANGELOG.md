## 0.1.1

Package updates to Debian stable (Jessie) builds.

Addition of base/builder - A build environment for building tklx/base from
tklx/base. See the README for details.

#### Bugfixes

- unit.d/bashrc: escape tilde used for HOME representation.

#### Other changes

- codename: create and use /etc/debian_codename to determine version.
- makefile: require RELEASE be set in environment.
- makefile: correctly determine paths for debootstrap.
- docker: added docker files for building image from build/rootfs.tar.gz
- builder: tklx/base build environment supporting jessie, stretch, sid.

#### Package updates

```
gnupg 1.4.18-7+deb8u1		     |	gnupg 1.4.18-7+deb8u2
gpgv 1.4.18-7+deb8u1		     |	gpgv 1.4.18-7+deb8u2
libgcrypt20 1.6.3-2+deb8u1	     |	libgcrypt20 1.6.3-2+deb8u2
perl-base 5.20.2-3+deb8u5	     |	perl-base 5.20.2-3+deb8u6
```

## 0.1.0

Initial development release based on Debian stable (Jessie).

#### Notes

- Based off turnkeylinux/bootstrap and turnkeylinux/fab/share.
- Imported files refactored, rewritten and tweaked (see git log).

- APT configurations

    - Don't install recommends by default.
    - Don't download translation files.
    - Explicitly request gzipped indexes, keep compressed on-disk.
    - Ensure APT is aggressive about removing packages it added.
    - Prevent initscripts from running during install/update.
    - Use httpredir.debian.org for fastest geo-location updates.
    - Only main repo enabled (contrib, non-free commented out).

- APT clean convenience script: apt-clean [--aggressive]

    - Cleans all APT related cached files.
    - Supports optional --aggressive option to clean docs, locales,
      manpages, info, groff, linda and lintian. Note that copyright
      files are *not* deleted.
    - Locale to exclude from aggressive clean is determined from
      environment variable LANG. If not set, ``en_*`` is assumed.

- Bashrc

    - Set PS1 (promptpath) to max 2 levels (readability, usefulness).
    - Enable color support when possible.

