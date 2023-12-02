# mojo_nix

A Nix flake to package the Mojo language.

## Updating `modular`

Simply run

```console
nix run .#modular.updateScript
```

## Working with `modular`

To get a shell with `modular` available, run

```console
export MODULAR_AUTH=<your auth key>
nix develop .#modular
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
