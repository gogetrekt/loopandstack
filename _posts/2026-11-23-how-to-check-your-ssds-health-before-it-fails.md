---
title: "How to Check Your SSD's Health Before It Fails"
date: 2026-11-23 15:12:00 +0700
categories: [Hardware]
tags: [ssd, nvme, smart, storage, crystaldiskinfo, health]
description: "Your SSD keeps a wear odometer and most people never look at it. Three numbers tell you whether your drive will outlive your laptop, and checking them takes about two minutes."
author: elena
image:
  path: /assets/img/posts/ssd-health-check-lead.svg
  alt: "A hand holding an M.2 NVMe SSD in front of a laptop (Photo: Crucial)"
og_image: /assets/og/how-to-check-your-ssds-health-before-it-fails.png
faq:
  - q: "Does 100% Percentage Used mean my SSD is dead?"
    a: "No. It means you have used up the write endurance the manufacturer rated the drive for. The drive can keep working past 100%, but it is past its warranted life, so treat it as a replacement candidate and make sure your backups are current."
  - q: "How long does an SSD last in normal use?"
    a: "Longer than most people expect. Backblaze tracked 2,906 SSD boot drives and recorded an annualized failure rate of 0.98% in 2022, against 1.64% for hard drives. A typical consumer drive writing a normal amount of data should outlive the laptop it sits in."
  - q: "Can I trust the Good badge in CrystalDiskInfo?"
    a: "Mostly, but read the rows underneath it. The badge is a summary of thresholds, and a drive can show Good while an error counter is quietly climbing. Percentage Used, Available Spare, and Media and Data Integrity Errors are the three numbers that matter."
  - q: "Does checking my SSD's health void the warranty?"
    a: "No. Reading SMART data is read-only. Your warranty ends at five years or the rated TBW, whichever comes first, and no health check changes either number."
---

Your SSD will probably not warn you before it dies. Hard drives click and grind on the way out. SSDs just vanish one morning, or turn read-only in the middle of a save. The good news is that your drive has been keeping score the whole time. It tracks how much of its rated life you have burned, how many spare blocks are left, and how many times it failed to return your data intact. Reading those three numbers takes about two minutes, and it is the difference between replacing a drive on your schedule and losing a weekend to recovery.

Here is the short version. On an NVMe drive, check Percentage Used, Available Spare, and Media and Data Integrity Errors. On a SATA drive, check Reallocated Sector Count, Current Pending Sector Count, and Uncorrectable Sector Count. The rest of this article is where to find those numbers on Windows, macOS, and Linux, and what to do when one of them looks wrong.

## SSDs fail differently, so the old rules do not apply

The failure math is kinder than the folklore. Backblaze tracked 2,906 SSD boot drives and recorded an annualized failure rate of 0.98% in 2022, against 1.64% for hard drives. About one drive in a hundred fails in a given year.

But the shape of failure is different, and that is what catches people. A hard drive usually degrades in public: slow reads, strange noises, sectors going bad one at a time. An SSD has two ways to die. The slow one is NAND wear, as every write erases and rewrites flash cells that survive only a limited number of cycles, and the controller quietly retires worn blocks for spares from a reserve the operating system never sees. The fast one is the controller itself, a firmware bug, or a power event, and that one gives no warning at all.

That split is why a single health percentage is a trap. It is a wear estimate. It says nothing about the controller or the error counters, so a drive at 95% remaining life with a rising error count is in more danger than a drive at 60% with clean counters. Read the numbers, not the badge.

## The three numbers that matter on NVMe

The NVMe specification defines the health log, so every NVMe drive reports the same fields with the same meanings, whatever brand is on the label.

**Percentage Used.** The controller's estimate of how much of the drive's rated write endurance you have consumed. Zero is a fresh drive, 100 means the rated endurance is used up. Two details matter. First, it is an estimate, not a measurement of your writes: write amplification pushes it ahead of the simple math of bytes written divided by the TBW rating. Second, it can exceed 100, and a drive past 100 is past its warranted endurance, not dead. Treat anything above 80 as the point to plan a replacement.

**Available Spare.** SSDs hold back reserve blocks to replace worn-out ones. This field is the percentage of that reserve still unused, starting at 100. It only means something next to the Available Spare Threshold, usually 10%. When the spare drops below the threshold, the drive raises a critical warning. A spare that is falling fast is a worse sign than a Percentage Used that is merely high.

**Media and Data Integrity Errors.** The times the controller could not return your data: uncorrectable ECC failures, failed CRC checks, failed address checks. Healthy is zero, and zero is the only number you want to see here. Any number above zero means the drive has already failed to read something, even if the operating system retried and you never noticed. Back up first, ask questions later. Also glance at Critical Warning, a single byte where each bit is a separate alarm: anything other than zero means the drive has already decided something is wrong.

## The three numbers that matter on SATA

SATA SSDs speak an older dialect: a table of SMART attributes with vendor-specific IDs. The names vary by brand, but the three rows to find are the same on every drive.

**Reallocated Sector Count (ID 05).** Bad blocks the firmware already swapped out for spares. Any number above zero means the drive has started eating into its reserve. A small count on an old drive is normal wear. A count that climbs week to week is not.

**Current Pending Sector Count (ID C5).** Sectors that failed a read and are waiting to be remapped. These cause freezes and stalled file copies, because the drive keeps retrying them. This number should be zero.

**Uncorrectable Sector Count (ID C6).** Sectors the drive could not recover even with error correction. Like Media Errors on NVMe, this should be zero, permanently. Anything else is a backup-now event.

SATA drives also report wear, but the attribute name is vendor-specific: Samsung calls it Wear Leveling Count, others use SSD Life Left. If the raw table looks like alphabet soup, use the manufacturer's utility instead. Samsung Magician, WD Dashboard, Kingston SSD Manager, and Crucial Storage Executive all translate their own drive's attributes into plain language, and they handle firmware updates too.

## Windows: the built-in check, then the real one

Windows 11 has a drive health panel, and it is the fastest check you will ever run. Open Settings, go to System, then Storage, then Advanced storage settings, then Disks and volumes. Pick your drive, click Properties, and read the Drive health section: estimated remaining life, available spare, and temperature.

The catch is in the fine print. Microsoft monitors NVMe SSDs only, not SATA SSDs and not hard drives, so a SATA boot drive shows no Drive health section at all. And the panel is a summary, not a diagnosis. Use it for a 30-second sanity check, then get the full picture from a tool that shows the raw log.

CrystalDiskInfo is the free standard for that. Download it from the author's site, crystalmark.info, and skip third-party mirrors. The current release is 9.9.4, from November 2026, and the portable ZIP runs without installing anything. Open it, pick your drive, and read the Health Status badge, then scroll past it to the attribute table and find the rows from the sections above. Good is blue, Caution is yellow, Bad is red. Caution means an attribute crossed its threshold, and the drive will often keep running for months and then fall off a cliff in a week, so treat Caution as a deadline.

If you would rather not install anything, PowerShell reads the same data Windows already collects. In an administrator PowerShell, run:

```
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object DeviceId, Wear, Temperature, PowerOnHours, ReadErrorsTotal
```

The Wear column is the endurance estimate as a percentage, and it works for SATA drives too. One gotcha: drives in USB enclosures often report nothing, because the enclosure's bridge chip has to pass SMART commands through and cheap ones do not. If a tool shows no data for an external drive, connect it directly before concluding anything.

## macOS: the built-in answer is vague, so go one layer deeper

Apple gives you a yes-or-no answer and stops there. Open Disk Utility, select the physical disk rather than a volume, click Info, and look for the S.M.A.R.T. status. Verified means no reported problems. Failing means the drive has an error that will soon become fatal. That is the whole report, and it does not tell you how worn the drive is.

For the real numbers, install smartmontools with Homebrew and run it in Terminal:

```
brew install smartmontools
diskutil list
sudo smartctl -a /dev/disk0
```

Use the identifier from `diskutil list` for your internal drive, usually disk0. The output is the full NVMe health log. If the command line is not your thing, DriveDx is the paid Mac utility that watches the same data continuously and shows a lifetime-left indicator. Either way, do not settle for Verified. Verified is the drive saying nothing is on fire yet.

## Linux: two commands and you are done

Linux is the most straightforward of the three. Install smartmontools or nvme-cli from your distribution's repositories, then run:

```
sudo smartctl -a /dev/nvme0
sudo nvme smart-log /dev/nvme0
```

The first prints the full report including the error log and self-test history. The second prints the NVMe health log on one screen. For a SATA drive, replace `/dev/nvme0` with the device name, usually `/dev/sda`. Check the device name first with `lsblk`, because the wrong device gives you a clean bill of health for a drive you do not own.

## Do the TBW math before you panic

Percentage Used is a vendor estimate, so cross-check it against the drive's rated endurance, which is printed on the spec sheet. The Samsung 990 Pro 1TB is rated at 600 TBW with a five-year warranty, whichever comes first: roughly 328 GB of writes every single day for five years. The 2TB model is rated 1,200 TBW and the 4TB model 2,400 TBW.

Compare that with your actual writes, from the Data Units Written field in the NVMe log. Most desktop users write a few terabytes a year, which puts a 600 TBW drive decades from its rating. Video editors and anyone running a database on a consumer drive are the people who actually get there. If your writes are ordinary and your Percentage Used is under 50, stop worrying about wear and check the error counters instead. They are the numbers that kill drives early.

| Reading | What it means | What to do |
|---|---|---|
| Percentage Used under 50%, errors at 0 | Normal wear, healthy drive | Check again in six months |
| Percentage Used 80 to 100% | Rated endurance nearly used up | Plan a replacement, keep backups current |
| Percentage Used over 100% | Past warranted endurance | Replace soon, the warranty is spent |
| Media Errors or Uncorrectable Sectors above 0 | The drive has already failed to return data | Back up now, replace the drive |
| Critical Warning other than 0 | The drive itself has raised an alarm | Back up now, replace the drive |
| Reallocated or Pending Sectors climbing | The drive is eating its spare blocks | Back up now, replace the drive |

## When a number looks bad

Back up before anything else. Not after checking the warranty, not after updating the firmware. A drive that is throwing errors can get worse while you research, and a backup is the only step that cannot wait. Clone the drive or copy your files to a second disk, then verify the copy opens.

Next, check the warranty. Most consumer SSDs carry five years or the TBW rating, whichever comes first, and a drive failing inside either limit is a warranty claim, not a purchase. Save a screenshot or a text export of the health log before you send the drive back.

Then check for a firmware update in the vendor's tool. Firmware bugs have caused real waves of failures, and vendors fix them quietly. An update will not resurrect worn NAND, but it can fix a controller bug that is throwing errors. Do not update firmware on a drive you have not backed up yet.

Finally, remember what a health check is not. It is not a backup, and it cannot predict the controller failures that strike without warning. The health log catches wear and the slow failures. Backups catch everything else. If your files live on exactly one SSD, the health numbers are the least of your problems. Back up the drive, and if it is encrypted with BitLocker, [back up the 48-digit recovery key too](/posts/bitlockers-tpm-only-default-is-the-weak-link-add-a-preboot-pin/): a dead drive with no recovery key is two problems at once. If you are on Linux and wondering what else lives on that disk, [our manual Arch install walks through partitioning it properly](/posts/how-to-install-arch-linux-manually-without-archinstall/).

SSDs do not last forever, but they last longer than their reputation suggests, and they keep a careful diary of their own decline. Spend two minutes reading it. The drive is already doing its part.

## Frequently asked questions

**Does 100% Percentage Used mean my SSD is dead?**

No. It means you have used up the write endurance the manufacturer rated the drive for. The drive can keep working past 100%, but it is past its warranted life, so treat it as a replacement candidate and make sure your backups are current.

**How long does an SSD last in normal use?**

Longer than most people expect. Backblaze tracked 2,906 SSD boot drives and recorded an annualized failure rate of 0.98% in 2022, against 1.64% for hard drives. A typical consumer drive writing a normal amount of data should outlive the laptop it sits in.

**Can I trust the Good badge in CrystalDiskInfo?**

Mostly, but read the rows underneath it. The badge is a summary of thresholds, and a drive can show Good while an error counter is quietly climbing. Percentage Used, Available Spare, and Media and Data Integrity Errors are the three numbers that matter.

**Does checking my SSD's health void the warranty?**

No. Reading SMART data is read-only. Your warranty ends at five years or the rated TBW, whichever comes first, and no health check changes either number.
