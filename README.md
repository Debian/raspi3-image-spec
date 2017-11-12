# Raspberry Pi 3 image spec

This repository contains the files with which the image referenced at
https://wiki.debian.org/RaspberryPi3 has been built.

## Option 1: Downloading an image

See https://wiki.debian.org/RaspberryPi3#Preview_image for where to obtain the latest pre-built image.

## Option 2: Building your own image

If you prefer, you can build a Debian buster Raspberry Pi 3 image yourself. For
this, first install the
[requirements](https://github.com/larswirzenius/vmdb2/blob/master/README#getting-vmdb2)
of vmdb2. Then run the following:

```shell
git clone --recursive https://github.com/Debian/raspi3-image-spec
cd raspi3-image-spec
```

Then edit [raspi3.yaml](raspi3.yaml) to select the Debian repository that you
want to use:

- If you want to use the snapshot with which the build was tested, use
    `http://snapshot.debian.org/archive/debian/20171007T213914Z/`. This is what
    is pre-configured in raspi3.yaml. However, due to a [missing
    feature](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=763419) on
    snapshots, to make the build work, you have to disable an expiration check
    by APT. To do so, edit raspi3.yaml to replace all
    `apt-get` invocations with `apt-get -o Acquire::Check-Valid-Until=false`
- If you want to use the latest versions of each software, you can replace
    `http://snapshot.debian.org/archive/debian/20171007T213914Z/` in raspi3.yaml
    with `http://deb.debian.org/debian`. Of course, this means that the
    build may break or fail to boot if there are regressions in the latest
    versions.

Once you have edited raspi3.yaml, you can generate the image by
issuing the following:

```shell
umask 022
sudo env -i LC_CTYPE=C.UTF-8 PATH="$PATH" \
    ./vmdb2/vmdb2 --output raspi3.img raspi3.yaml --log raspi3.log
```

## Installing the image onto the Raspberry Pi 3

Plug an SD card which you would like to entirely overwrite into your SD card reader.

Assuming your SD card reader provides the device `/dev/sdb`, copy the image onto the SD card:

```shell
sudo dd if=raspi3.img of=/dev/sdb bs=5M
```

Then, plug the SD card into the Raspberry Pi 3 and power it up.

The image uses the hostname `rpi3`, so assuming your local network correctly resolves hostnames communicated via DHCP, you can log into your Raspberry Pi 3 once it booted:

```shell
ssh root@rpi3
# Enter password “raspberry”
```

Note that the default firewall rules only allow SSH access from the local
network. If you wish to enable SSH access globally, first change your root
password using `passwd`. Next, issue the following commands to remove the
corresponding firewall rules:

```shell
sudo iptables -D INPUT 6
sudo ip6tables -D INPUT 4
```

This will allow SSH connections globally until the next reboot. To make this
persistent, remove the lines containing "REJECT" in `/etc/iptables/rules.v4` and
`/etc/iptables/rules.v6`.

