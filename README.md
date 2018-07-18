# Raspberry Pi 3 image spec

This repository contains the files with which the image referenced at
https://wiki.debian.org/RaspberryPi3 has been built.

## Option 1: Downloading an image

See https://wiki.debian.org/RaspberryPi3#Preview_image for where to obtain the latest pre-built image.

## Option 2: Building your own image

If you prefer, you can build a Debian buster Raspberry Pi 3 image
yourself. If you are reading this document online, you should first
clone this repository:

```shell
git clone --recursive https://github.com/Debian/raspi3-image-spec
cd raspi3-image-spec
```

For this you will first need to install `vmdb2`. As of July 2018, this
repository still ships vmdb2, but will probably be deprecated in the
future. You can choose:

- `vmdb2` is available as a package for Testing and Unstable. If your
  Debian system is either, quite probably installing it systemwide is
  the easiest and most recommended way.

- If you are using Debian stable (stretch) or for some reason prefer
  not to install the package, `vmdb2` is presented as a submodule in
  this project. First install the
  [requirements](http://git.liw.fi/vmdb2/tree/README) of `vmdb2`:

	```shell
	apt install kpartx parted qemu-utils qemu-user-static python3-cliapp \
    python3-jinja2 python3-yaml
	```

  Note that `python3-cliapp` is not available in Stretch, but as it
  does not carry any dependencies, can be manually installed by
  [fetching its .deb package ](https://packages.debian.org/buster/python3-cliapp)
  and installing it manually.

Then edit [raspi3.yaml](raspi3.yaml) to select the Debian repository that you
want to use:

- The images now build correctly with the main repository! If you want
  to build your image following the regular Testing (*buster*)
  distribution, leave `raspi3.yaml` as it is
    - Stable (*stretch*) is not supported, as we require linux ≥ 4.14
      and raspi3-firmware ≥ 1.20171201-1.

- Testing is, however, constantly changing. You might want to choose a
  specific point in its history to build with. To do this, locate the
  line with `qemu-debootstrap: buster` in `raspi3.yaml`. Change
  `mirror: http://deb.debian.org/debian` to `mirror:
  http://snapshot.debian.org/archive/debian/20171007T213914Z/`. 
    - Due to a
      [missing feature](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=763419)
      on snapshots, to make the build work, you have to disable an
      expiration check by APT. To do so, edit raspi3.yaml to replace
      all `apt-get` invocations with `apt-get -o
      Acquire::Check-Valid-Until=false`

Once you have edited raspi3.yaml, you can generate the image by
issuing the following. If you are using the systemwide `vmdb2`:

```shell
umask 022
sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$PATH" \
    vmdb2 --output raspi3.img raspi3.yaml --log raspi3.log
```

Or, if you are using it from the submodule in this repository

```shell
umask 022
sudo env -i LC_CTYPE=C.UTF-8 PATH="/usr/sbin:/sbin:$PATH" \
    ./vmdb2/vmdb2 --output raspi3.img raspi3.yaml --log raspi3.log
```

## Installing the image onto the Raspberry Pi 3

Plug an SD card which you would like to entirely overwrite into your SD card reader.

Assuming your SD card reader provides the device `/dev/sdb`, copy the image onto the SD card:

```shell
sudo dd if=raspi3.img of=/dev/sdb bs=64k oflag=dsync status=progress
```

Then, plug the SD card into the Raspberry Pi 3 and power it up.

The image uses the hostname `rpi3`, so assuming your local network correctly resolves hostnames communicated via DHCP, you can log into your Raspberry Pi 3 once it booted:

```shell
ssh root@rpi3
# Enter password “raspberry”
```

Note that the default firewall rules only allow SSH access from the local
network. If you wish to enable SSH access globally, first change your root
password using `passwd`. Next, issue the following commands as root to remove
the corresponding firewall rules:

```shell
iptables -F INPUT
ip6tables -F INPUT
```

This will allow SSH connections globally until the next reboot. To make this
persistent, remove the lines containing "REJECT" in `/etc/iptables/rules.v4` and
`/etc/iptables/rules.v6`.

