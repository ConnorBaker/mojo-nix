# mojo_nix

A Nix flake to package the Mojo language.

> [!Warning]
> Attempting to run `mojo` results in the following error:
>
> ```console
> /tmp/modular/pkg/packages.modular.com_mojo/bin/lldb: /nix/store/5i51nfixxx3p3gshkfsjj4bzp7wajwxz-ncurses-6.4/lib/libpanel.so.6: version `NCURSES6_5.0.19991023' not found (required by /tmp/modular/pkg/packages.modular.com_mojo/lib/liblldb.so.18git)
> /tmp/modular/pkg/packages.modular.com_mojo/bin/lldb: /nix/store/5i51nfixxx3p3gshkfsjj4bzp7wajwxz-ncurses-6.4/lib/libtinfo.so.6: version `NCURSES6_5.0.19991023' not found (required by /tmp/modular/pkg/packages.modular.com_mojo/lib/liblldb.so.18git)
> ```
>
> The current version of `ncurses` in use does not match what `mojo` expects.

## Updating `modular`

Simply run

```console
nix run .#modular.updateScript
```

## Using `mojo`

To get a shell with `mojo` available, run

```console
export MODULAR_AUTH=<your auth key>
nix develop .#mojo
```

## Background

Mojo is typically installed via `apt` repository. The documentation instructs the user to run the following as root:

```console
apt-get install -y apt-transport-https &&
  keyring_location=/usr/share/keyrings/modular-installer-archive-keyring.gpg &&
  curl -1sLf 'https://dl.modular.com/bBNWiLZX5igwHXeu/installer/gpg.0E4925737A3895AD.key' |  gpg --dearmor >> ${keyring_location} &&
  curl -1sLf 'https://dl.modular.com/bBNWiLZX5igwHXeu/installer/config.deb.txt?distro=debian&codename=wheezy' > /etc/apt/sources.list.d/modular-installer.list &&
  apt-get update &&
  apt-get install -y modular
```

That command adds the following sources to `apt`:

```text
# Source: Modular
# Site: https://cloudsmith.io
# Repository: Modular / Installer
# Description: A certifiably-awesome public package repository curated by Modular, hosted by Cloudsmith.


deb [signed-by=/usr/share/keyrings/modular-installer-archive-keyring.gpg] https://dl.modular.com/public/installer/deb/debian wheezy main

deb-src [signed-by=/usr/share/keyrings/modular-installer-archive-keyring.gpg] https://dl.modular.com/public/installer/deb/debian wheezy main
```

It then fetches the package index, which lives at `https://dl.modular.com/public/installer/deb/debian/dists/wheezy/main/binary-amd64/Packages.gz`.

With the package index, `apt` then retrieves the latest version. Using the package index, the latest version has a filename of `pool/any-version/main/m/mo/modular_0.2.2/modular-v0.2.2-amd64.deb`, so `apt` fetches the `.deb` installer from `https://dl.modular.com/public/installer/deb/debian/pool/any-version/main/m/mo/modular_0.2.2/modular-v0.2.2-amd64.deb`.
