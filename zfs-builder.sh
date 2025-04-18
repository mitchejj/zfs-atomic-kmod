#!/usr/bin/bash

set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
RELEASE="$(rpm -E '%fedora')"

# allow pinning to a specific release series (eg, 2.0.x or 2.1.x)
# ZFS_MINOR_VERSION="${ZFS_MINOR_VERSION:-}"

sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo

# fedora image has no kernel so this needs nothing fancy, just install
# dnf install -y --no-docs  kernel kernel-headers
# KERNEL_VERSION=$(rpm -q kernel | cut -d '-' -f2-)
# KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"

# fedora image has no kernel, install with some tooling
dnf install -y \
  kernel \
  kernel-headers \
  akmods \
  autoconf \
  automake \
  dkms \
  git \
  jq \
  libtool \
  ncompress

# protect against incorrect permissions in tmp dirs which can break akmods builds
chmod 1777 /tmp /var/tmp
cd /tmp

# Use cURL to fetch the given URL, saving the response to `data.json`
curl "https://api.github.com/repos/openzfs/zfs/releases" -o data.json
ZFS_VERSION=$(jq -r --arg ZMV "zfs-${ZFS_MINOR_VERSION}" '[ .[] | select(.prerelease==false and .draft==false) | select(.tag_name | startswith($ZMV))][0].tag_name' data.json|cut -f2- -d-)
echo "ZFS_VERSION==$ZFS_VERSION"

### zfs specific build deps
dnf install -y \
  elfutils-libelf-devel \
  libaio-devel \
  libattr-devel \
  libblkid-devel \
  libcurl-devel \
  libffi-devel \
  libtirpc-devel \
  libudev-devel \
  libuuid-devel \
  openssl-devel \
  python3-devel \
  python3-setuptools

### BUILD zfs
echo "getting zfs-${ZFS_VERSION}.tar.gz"
curl -L -O "https://github.com/openzfs/zfs/releases/download/zfs-${ZFS_VERSION}/zfs-${ZFS_VERSION}.tar.gz"

tar -z -x --no-same-owner --no-same-permissions -f zfs-${ZFS_VERSION}.tar.gz

# patch the zfs-kmod.spec.in file for older zfs versions
# ZFS_MAJ=$(echo $ZFS_VERSION | cut -f1 -d.)
# ZFS_MIN=$(echo $ZFS_VERSION | cut -f2 -d.)
# ZFS_PATCH=$(echo $ZFS_VERSION | cut -f3 -d.)

KERNEL="$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
cd /tmp/zfs-${ZFS_VERSION}
./configure \
        -with-linux=/usr/src/kernels/${KERNEL}/ \
        -with-linux-obj=/usr/src/kernels/${KERNEL}/ \
    && make -j $(nproc) rpm-utils rpm-kmod


# create a directory for later copying of resulting zfs specific artifacts
mkdir -p /var/cache/rpms/kmods/zfs/{debug,devel,other,src} \
    && mv *src.rpm /var/cache/rpms/kmods/zfs/src/ \
    && mv *devel*.rpm /var/cache/rpms/kmods/zfs/devel/ \
    && mv *debug*.rpm /var/cache/rpms/kmods/zfs/debug/ \
    && mv zfs-dracut*.rpm /var/cache/rpms/kmods/zfs/other/ \
    && mv zfs-test*.rpm /var/cache/rpms/kmods/zfs/other/ \
    && mv *.rpm /var/cache/rpms/kmods/zfs/


# Ensure packages get copied to /var/cache/rpms
if [ -d /var/cache/akmods ]; then
    for RPM in $(find /var/cache/akmods/ -type f -name \*.rpm); do
        cp "${RPM}" /var/cache/rpms/kmods/
    done
fi

if [ -d /root/rpmbuild/RPMS/"$(uname -m)" ]; then
    for RPM in $(find /root/rpmbuild/RPMS/"$(uname -m)"/ -type f -name \*.rpm); do
        cp "${RPM}" /var/cache/rpms/kmods/
    done
fi

find /var/cache/rpms

