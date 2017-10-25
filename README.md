# Raspberry Pi 3 image spec

This repository contains the files with which the image referenced at
https://wiki.debian.org/RaspberryPi3 has been built.

## Option 1: Downloading an image

See https://wiki.debian.org/RaspberryPi3#Preview_image for where to obtain the latest pre-built image.

## Option 2: Building your own image

If you prefer, you can build a Debian buster Raspberry Pi 3 image yourself. For
this, first run the following:

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
    by APT. To do so, edit [raspi3.yaml](raspi3.yaml) to replace all
    `apt-get` invocations with `apt-get -o Acquire::Check-Valid-Until=false`
- If you want to use the latest versions of each software, you can replace
    `http://snapshot.debian.org/archive/debian/20171007T213914Z/` in raspi3.yaml
    with the URL of your favorite Debian mirror. Of course, this means that the
    build may break if there are regressions in the latest versions.

Once you have edited [raspi3.yaml](raspi3.yaml), you can generate the image by
issuing:

```shell
sudo ./vmdb2/vmdb2 --output raspi3.img raspi3.yaml --log raspi3.log
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

