# zfs-atomic-kmod
TODO: Add build badge

## What is this?
This a redo of my previous ostree-zfs-kmods, this is a derivation is a downstream distillation of ublue-os/akmods

The `zfs-atomic-kmod-build` workflow is set to run at 7:05 UTC Mon, Tues, and Wed.

### NOTE: Due to the kernel's tendency to occasionally 'break' ZFS compatibility, it may take several days or weeks for a compatible ZFS version to be released.

## Usage

Basic example: [Container.example][example]

[example]: https://github.com/mitchejj/zfs-atomic-kmod/blob/main/Containerfile.example


## Features
Nothing special just `zfs-2.3.x`. The main goal is to provide an easy way
reproduce this repo and build the zfs modules. 

### NOTE: the ZFS kmods are not yet signed to enable secure boot
### NOTE: that the `*.tar.gz` source files are not cryptographically verified, which may pose a security risk due to the lack of integrity and authenticity checks.




### Reading

* [kernel - Fedora Packages](https://packages.fedoraproject.org/pkgs/kernel/kernel/)
* [OpenZFS on Linux](https://zfsonlinux.org/)
* [Custom Packages — OpenZFS documentation](https://openzfs.github.io/openzfs-docs/Developer%20Resources/Custom%20Packages.html)


