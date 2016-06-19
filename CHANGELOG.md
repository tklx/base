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

