---
title: "BitLocker's TPM-Only Default Is the Weak Link: Add a Preboot PIN"
date: 2026-11-23 08:38:00 +0700
categories: [Security Tools]
tags: [bitlocker, windows-11, tpm, encryption, fastunlock, security]
description: "BitLocker's TPM-only default unlocks your drive before the lock screen even appears. A preboot PIN closes that gap, and it takes about ten minutes to set up."
author: tomas
image:
  path: /assets/img/posts/bitlocker-preboot-pin-lead.svg
  alt: "A laptop showing a password prompt with a large padlock icon (Photo: WIN Technology)"
og_image: /assets/og/bitlockers-tpm-only-default-is-the-weak-link-add-a-preboot-pin.png
faq:
  - q: "Does a preboot PIN stop FastUnlock?"
    a: "It stops the scenario that matters most: a powered-off laptop that gets stolen. FastUnlock needs a machine that has already booted to its lock screen, and with TPM plus PIN the drive never unlocks until you type the PIN. It does not protect a laptop that is stolen while already running and locked."
  - q: "Will adding a PIN decrypt and re-encrypt my drive?"
    a: "No. Adding a TPM-and-PIN protector only changes how the encryption key is released at boot. The data stays encrypted throughout, and the change takes effect on the next restart."
  - q: "What happens if I forget the PIN?"
    a: "You fall back to the 48-digit BitLocker recovery key. That is why backing it up before you start is not optional. Without the PIN and without the recovery key, your data is gone."
  - q: "Can I use a preboot PIN on Windows 11 Home?"
    a: "No. Home uses Device Encryption instead of full BitLocker, and it has no Group Policy editor or startup PIN option. You need Windows 11 Pro, Enterprise, or Education."
---

Your BitLocker-encrypted laptop is not as locked as you think. On most Windows PCs, BitLocker runs in TPM-only mode. The TPM chip checks the boot files, decides nothing was tampered with, and hands over the encryption key without asking you anything. By the time the lock screen appears, your files are already readable.

That gap turned into a headline on November 19, when researcher Chaotic Eclipse published FastUnlock, a zero-day that uses Windows Narrator to climb out of the lock screen and run code on a fully patched Windows 11 machine. It needs physical access and a Microsoft account on the machine, and it only reaches a limited account, not admin. But it took the researcher about five minutes, and Microsoft has no patch and no CVE for it yet. The fix for the part you can control takes about ten minutes: add a preboot PIN, so your laptop asks for it before Windows even starts and a powered-off machine that gets stolen stays encrypted.

## Why TPM-only is the weak link

TPM-only BitLocker is good at one job and bad at another. It protects a drive that gets pulled out of a machine, or a machine whose boot files were tampered with. In both cases the TPM refuses to release the key and Windows drops into recovery mode.

It is bad at protecting a machine someone is sitting in front of. Once the TPM has done its check, the drive is unlocked and the lock screen is all that stands between a stranger and your files. FastUnlock walked through it: from the "I forgot my PIN" prompt, Win+U summons Narrator, a few key presses open its settings, and a USB stick opens File Explorer. Anything started from there runs as WsiAccount, the limited lock-screen account. ThreatLocker reproduced the chain the same day.

FastUnlock does not break BitLocker's encryption or recover the key. It walks in after the drive has already unlocked itself, which is exactly what TPM-only is designed to do. Microsoft's own [documentation](https://learn.microsoft.com/en-us/windows/security/operating-system-security/data-protection/bitlocker/countermeasures) calls TPM-only "more convenient for sign-in but less secure than the other options, which require an additional authentication factor."

## What a preboot PIN changes

With TPM plus PIN, the encryption key does not enter memory until you type the PIN at boot. Microsoft puts it plainly: the only way past preboot authentication is the recovery key. That closes the window FastUnlock uses, because a stolen laptop that is powered off never reaches the lock screen at all.

The PIN is 4 to 20 digits, and 6 to 20 if you never set a minimum-length policy. Use at least 8, and skip birth years and repeating patterns. The TPM throttles repeated wrong guesses, which is what makes a short numeric PIN viable at all. You can allow letters and symbols with the "Allow enhanced PINs for startup" policy, but keep it typable: the preboot prompt is a bare screen. And the startup PIN is not your Windows Hello PIN or the 48-digit recovery key. Those are three different secrets.

| | TPM-only (default) | TPM + PIN |
|---|---|---|
| Asked for anything at boot | No | Yes, the PIN |
| Drive readable at the lock screen | Yes | No, until the PIN is entered |
| Protects a powered-off stolen laptop | Partly, it boots straight to the lock screen | Yes, it never gets past boot |
| Protects a laptop stolen while running | No | No, the drive is already unlocked |

## Before you start

You need Windows 11 Pro, Enterprise, or Education. Home uses Device Encryption instead of full BitLocker, and it has no Group Policy editor or startup PIN option. BitLocker must already be turned on for your C: drive, and you need an administrator account. If the PC is managed by your employer, ask IT first. A domain policy can overwrite your local changes.

Most important: back up your 48-digit recovery key before you touch anything. Open Control Panel, go to System and Security, then BitLocker Drive Encryption, and use "Back up your recovery key" on the C: drive. Save it to your Microsoft account, a password manager, or a printed copy kept somewhere other than next to the laptop. Do not store your only copy on the encrypted drive itself. If you forget the PIN and lose the recovery key, your data is gone.

## Step 1: Check what protects your drive now

Open an administrator Command Prompt. Right-click the Start button and pick Terminal (Admin) or Command Prompt (Admin), then run:

```
manage-bde -status C:
```

Look at the "Key Protectors" line. If it lists only TPM, you are on TPM-only, the default for most factory-encrypted machines. Also confirm "Protection Status" says Protection On and "Percentage Encrypted" says 100%. If the drive is still encrypting, wait for it to finish before changing protectors.

## Step 2: Allow the PIN in Group Policy

Windows will not let you add a startup PIN until a policy says it is allowed. Press Win+R, type `gpedit.msc`, and press Enter. In the left pane, go to Computer Configuration, then Administrative Templates, then Windows Components, then BitLocker Drive Encryption, then Operating System Drives.

Double-click "Require additional authentication at startup". Select Enabled. Under "Configure TPM startup PIN", pick "Require startup PIN with TPM". Click OK, then back in your administrator Command Prompt run:

```
gpupdate /force
```

If you skip this step, the next command refuses with error 0x80310060, which is Windows telling you the policy does not allow the protector. Set only one startup option to Required. If you also mark the startup key as Required, the policy conflicts and the PIN will not add.

## Step 3: Add the PIN

In the same administrator Command Prompt, run:

```
manage-bde -protectors -add c: -TPMAndPIN
```

You will be prompted to type the PIN. Nothing appears on screen as you type, which is normal. Type it twice to confirm.

This does not decrypt and re-encrypt your drive. Adding a TPM-and-PIN protector only changes how the encryption key is released at boot, so it takes seconds. At this point your drive has two protectors: the old TPM-only one and the new TPM-and-PIN one. While the TPM-only protector still exists, the machine can still boot without the PIN. Do not delete anything yet.

## Step 4: Make the PIN mandatory, then test it

Reboot. You should see the PIN prompt before the Windows logo appears. Type the PIN and confirm Windows starts normally. If the prompt never appears, the policy from step 2 did not apply, so run `gpupdate /force` again and recheck the setting.

Once the PIN prompt works, remove the old TPM-only protector so the PIN is actually required at every boot:

```
manage-bde -protectors -delete C: -type tpm
```

Reboot once more and confirm you are asked for the PIN every time. To change the PIN later, run `manage-bde -changepin C:` from an administrator Command Prompt.

## The limits, stated plainly

A preboot PIN is a strong fix for one scenario and no fix for another. It protects a machine that has not started yet. A laptop stolen while running and locked is still exposed, because the drive is already unlocked. The [Hacker News report on FastUnlock](https://thehackernews.com/2026/11/new-unpatched-windows-0-day-fastunlock.html) says the same: a startup PIN protects only a machine that has not yet started, not one already on the lock screen.

So the habit matters as much as the setting. Shut down or hibernate before the laptop leaves your sight. Sleep does not count: everything stays in memory and the drive stays unlocked, so no PIN is asked on wake. Hibernate locks the drive, and the PIN is required on resume.

It also does not stop a determined attacker with hardware tools and hours alone with the machine. And every reboot for a Windows update now needs you at the keyboard. For home laptops that is a fair trade.

None of that makes the PIN pointless. Most stolen laptops are powered off when they are taken, and most lock-screen attacks need the drive already unlocked. A preboot PIN takes that easy path away for a few seconds at every boot.

The same thinking applies to your phone, where the bootloader is the equivalent weak link. Our piece on [what GrapheneOS actually said](/posts/grapheneos-says-google-is-coming-for-your-bootloader/) separates that claim from the evidence, and [what your Android phone tracks](/posts/your-android-phone-is-tracking-everywhere-you-go/) shows what a stock phone gives away even when it is locked.

## Frequently asked questions

**Does a preboot PIN stop FastUnlock?**

It stops the scenario that matters most: a powered-off laptop that gets stolen. FastUnlock needs a machine that has already booted to its lock screen, and with TPM plus PIN the drive never unlocks until you type the PIN. It does not protect a laptop that is stolen while already running and locked.

**Will adding a PIN decrypt and re-encrypt my drive?**

No. Adding a TPM-and-PIN protector only changes how the encryption key is released at boot. The data stays encrypted throughout, and the change takes effect on the next restart.

**What happens if I forget the PIN?**

You fall back to the 48-digit BitLocker recovery key. That is why backing it up before you start is not optional. Without the PIN and without the recovery key, your data is gone.

**Can I use a preboot PIN on Windows 11 Home?**

No. Home uses Device Encryption instead of full BitLocker, and it has no Group Policy editor or startup PIN option. You need Windows 11 Pro, Enterprise, or Education.
