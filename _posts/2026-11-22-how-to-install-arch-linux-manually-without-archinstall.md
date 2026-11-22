---
title: "How to Install Arch Linux Manually (Without archinstall)"
date: 2026-11-22 09:30:00 +0700
categories: [Linux]
tags: [arch-linux, linux, install-guide, systemd-boot, grub, pacstrap, uefi]
description: "Skip the guided installer and build Arch Linux by hand: partition, pacstrap, fstab, chroot, and a bootloader, following the Arch Wiki step by step."
author: jonas
image:
  path: /assets/img/posts/arch-manual-install-lead.svg
  alt: "The Arch Linux logo above a terminal line showing the pacstrap install command"
og_image: /assets/og/how-to-install-arch-linux-manually-without-archinstall.png
faq:
  - q: "Do I need archinstall to install Arch Linux?"
    a: "No. archinstall is the guided installer on the official ISO, and it is the sensible default for most people. A manual install follows the Arch Wiki installation guide instead, takes longer, and leaves you knowing exactly what is on your disk."
  - q: "Does it matter whether my PC boots UEFI or BIOS?"
    a: "Yes. Run cat /sys/firmware/efi/fw_platform_size in the live environment: 64 means 64-bit UEFI, and a missing file means BIOS or CSM mode. This guide covers UEFI with GPT; a BIOS install needs a different layout and GRUB instead of systemd-boot."
  - q: "How much disk space does a manual Arch install need?"
    a: "The Arch Wiki example layout uses a 1 GiB EFI system partition, at least 4 GiB of swap, and a root partition of at least 23 to 32 GiB. Plan on roughly 30 GiB as a practical minimum, more if you want a desktop environment and a few big applications."
  - q: "What if I pick the wrong firmware packages?"
    a: "The linux-firmware meta package installs the default set, so most hardware works out of the box. If something like Wi-Fi is missing after first boot, install the matching split package, such as linux-firmware-intel, with pacman. Add intel-ucode or amd-ucode for your CPU at install time."
---

Arch Linux has a guided installer now, and it is good. Boot the ISO, run `archinstall`, answer a few prompts, and you get a working system with systemd-boot, a firewall, and optional snapshots. For most people, that is the right call.

So why do it by hand? A manual install is the fastest way to actually understand the system you will live in. You pick the layout, you choose what gets installed, and when something breaks later, you know where to look. The [Arch Wiki installation guide](https://wiki.archlinux.org/title/Installation_guide) is the reference for every step below, and each section links to the Wiki page it comes from. Partitioning destroys data, so back up anything you care about first.

## Get the ISO and check it

Download the current release, 2026.11.01, from the [Arch download page](https://archlinux.org/download). It ships kernel 7.2.11 and the ISO is 1.2 GB. The download page lists the SHA256 and BLAKE2b checksums, plus PGP signature verification with GnuPG or Sequoia, and you should verify the image before you write it to a USB stick:

```
b2sum -c b2sums.txt
```

The same page walks through the PGP check. That takes an extra minute and it is the only way to know the ISO is genuinely from Arch.

Write the image to a USB stick with Rufus in DD mode on Windows, or `dd` on Linux (`dd bs=4M if=archlinux-2026.11.01-x86_64.iso of=/dev/sdX status=progress`). Double check the `of=` target with `lsblk` first. Writing to the wrong device wipes it, and there is no undo.

## Boot the live environment and check the basics

Boot from the USB stick and pick the first menu entry, "Arch Linux install medium". You land at a root prompt. Two checks come first.

Confirm how your machine booted. The Wiki's check is:

```
cat /sys/firmware/efi/fw_platform_size
```

A result of 64 means 64-bit UEFI, 32 means 32-bit UEFI, and a missing file means your machine booted in BIOS or CSM mode. The rest of this guide assumes 64-bit UEFI and GPT. If you are on BIOS, follow the Wiki's BIOS notes instead.

Then check the network. Wired connections usually just work. Test with `ping archlinux.org`. On Wi-Fi, run `iwctl`, then `station wlan0 connect "YourNetwork"`, and ping again.

## Partition the disk

List your disks with `lsblk` and identify the right one. NVMe drives show up as `/dev/nvme0n1` with partitions like `/dev/nvme0n1p1`; SATA drives use `/dev/sda` with `/dev/sda1`. Get this wrong and you wipe the wrong disk.

The Wiki's example UEFI layout is simple and it works:

| Mount point | Partition | Type | Size |
| --- | --- | --- | --- |
| /boot | EFI system partition | FAT32 | 1 GiB |
| [SWAP] | Linux swap | swap | At least 4 GiB |
| / | Linux root | ext4 | Remainder, at least 23 to 32 GiB |

Create the partitions with `cfdisk /dev/nvme0n1` (or your disk), choosing GPT as the label type. Then format them:

```
mkfs.fat -F 32 /dev/efi_system_partition
mkswap /dev/swap_partition
mkfs.ext4 /dev/root_partition
```

Replace the placeholder names with your real partitions, like `/dev/nvme0n1p1`. The swap size is a floor, not a target: 4 GiB is fine for a desktop with 16 GiB of RAM.

## Mount, then install the base system

Mount in the right order. Root first, then the EFI partition inside it, and switch swap on:

```
mount /dev/root_partition /mnt
mount --mkdir /dev/efi_system_partition /mnt/boot
swapon /dev/swap_partition
```

Now install the base system. The Wiki's command is:

```
pacstrap -K /mnt base linux linux-firmware
```

The `-K` flag initialises the package keyring in the new system. Older guides get two things wrong: `base-devel` is optional, not required, and `linux-firmware` still works as a package even though firmware is now split into per-vendor packages. The current meta package, `linux-firmware 20261019-1`, pulls in the default set. Add your CPU microcode to the same line: `intel-ucode` for Intel, `amd-ucode` for AMD.

Then generate the filesystem table and check it before moving on:

```
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

The `-U` flag mounts by UUID, which survives disk renames. If the file looks wrong, fix it now. A bad fstab is the classic reason a fresh install fails to boot.

## Chroot and configure the system

Enter the new system with:

```
arch-chroot -S /mnt
```

Note the `-S` flag, which the current Wiki guide uses. From here on, every command runs inside your installed system rather than the live ISO.

Set the time zone and clock:

```
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
```

Pick your region from `/usr/share/zoneinfo`, like `Europe/Berlin` or `Asia/Jakarta`. Then set the locale. Uncomment `en_US.UTF-8 UTF-8` in `/etc/locale.gen`, run `locale-gen`, and write `LANG=en_US.UTF-8` to `/etc/locale.conf`. Set the hostname with `echo myhostname > /etc/hostname`, and add matching entries to `/etc/hosts` for `127.0.0.1` and `::1`.

Set a root password with `passwd`, then create your daily user and give it sudo. Install sudo first (`pacman -S sudo`), then:

```
useradd -m -G wheel username
passwd username
```

Uncomment the `%wheel ALL=(ALL:ALL) ALL` line in `/etc/sudoers` with `EDITOR=nano visudo`. Never edit sudoers with a plain text editor: `visudo` checks the syntax before saving, and a broken sudoers file locks you out of admin rights.

## Install a bootloader

The Installation guide gives no bootloader command itself; it points you to the [Arch boot process](https://wiki.archlinux.org/title/Arch_boot_process) page to pick one and follow that loader's own instructions. For a first manual install on UEFI, systemd-boot is the simpler choice. Install it with:

```
bootctl install
```

Then create one entry file at `/boot/loader/entries/arch.conf`:

```
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=your-root-uuid rw
```

Find the UUID with `blkid`. The `root=UUID=` form survives disk renames.

If you dual boot with Windows or another Linux, or you are on BIOS, [GRUB](https://wiki.archlinux.org/title/GRUB) is the better pick. Install `grub` and `efibootmgr`, then run `grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB` followed by `grub-mkconfig -o /boot/grub/grub.cfg`. GRUB detects other operating systems with os-prober, which systemd-boot does not do on its own.

## Networking, reboot, first boot

Enable networking so it starts on boot. NetworkManager is the standard choice:

```
systemctl enable NetworkManager
```

Do not install dhcpcd alongside it; the two fight over the same interface. Then leave the chroot with `exit`, unmount everything with `umount -R /mnt`, and reboot.

If the boot menu appears and you reach a login prompt, the install worked. Log in as your user, run `ping archlinux.org` to confirm networking, and check for updates with `pacman -Syu`. A failed boot usually means the fstab is wrong, the bootloader entry points at the wrong UUID, or the EFI partition was never mounted when the bootloader installed.

## What you get, and what comes next

A base install boots to a console login. There is no desktop, no browser, no graphical anything, and that is by design. What comes next is yours to choose: a desktop environment like KDE Plasma or GNOME, a display manager, and an AUR helper like yay if you want community packages.

archinstall buys you speed and a tested default configuration. Doing it by hand buys you a system with nothing in it you did not put there, and the knowledge to fix it when it breaks.

## Frequently asked questions

**Do I need archinstall to install Arch Linux?**
No. archinstall is the guided installer on the official ISO, and it is the sensible default for most people. A manual install follows the Arch Wiki installation guide instead, takes longer, and leaves you knowing exactly what is on your disk.

**Does it matter whether my PC boots UEFI or BIOS?**
Yes. Run cat /sys/firmware/efi/fw_platform_size in the live environment: 64 means 64-bit UEFI, and a missing file means BIOS or CSM mode. This guide covers UEFI with GPT; a BIOS install needs a different layout and GRUB instead of systemd-boot.

**How much disk space does a manual Arch install need?**
The Arch Wiki example layout uses a 1 GiB EFI system partition, at least 4 GiB of swap, and a root partition of at least 23 to 32 GiB. Plan on roughly 30 GiB as a practical minimum, more if you want a desktop environment and a few big applications.

**What if I pick the wrong firmware packages?**
The linux-firmware meta package installs the default set, so most hardware works out of the box. If something like Wi-Fi is missing after first boot, install the matching split package, such as linux-firmware-intel, with pacman. Add intel-ucode or amd-ucode for your CPU at install time.

Keep reading: if you want a Linux app that respects the same do-it-yourself spirit, our [Hex Brings Your Voice to Your Device: A Dictation App That Never Touches the Cloud](/posts/hex-brings-your-voice-to-your-device-a-dictation-app-that-never-touches-the-cloud/) runs transcription fully on your machine. And if containers are more your speed, [Docker Just Renamed Itself: What Actually Changed for You](/posts/docker-just-renamed-itself-what-actually-changed-for-you/) explains the rebrand and the Desktop 4.100.0 release.
