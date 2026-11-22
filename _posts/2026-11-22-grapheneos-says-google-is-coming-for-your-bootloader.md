---
title: "GrapheneOS Says Google Is Coming for Your Bootloader"
date: 2026-11-22 15:12:00 +0700
categories: [Security Tools]
tags: [grapheneos, google, pixel, bootloader, android, privacy, play-integrity, custom-rom]
description: "GrapheneOS says Google is pressuring phone makers to drop it and predicts locked Pixel bootloaders. Here is what was actually said, what is proven, and what Pixel owners should do."
author: tomas
image:
  path: /assets/img/posts/grapheneos-bootloader-lead.svg
  alt: "The GrapheneOS logo next to a Pixel phone with a padlock on its screen"
og_image: /assets/og/grapheneos-says-google-is-coming-for-your-bootloader.png
faq:
  - q: "Has Google locked Pixel bootloaders?"
    a: "No. As of November 22, 2026, Google has announced nothing and has not responded to the accusation. The locked bootloader is GrapheneOS's prediction, not a Google plan, and nothing has changed for Pixel owners yet."
  - q: "Can I still install GrapheneOS today?"
    a: "Yes. GrapheneOS officially supports the Pixel 6a through the Pixel 10a, with extended support for the Pixel 6 and 6 Pro. You unlock the bootloader, flash the factory images, and relock it to GrapheneOS keys for verified boot."
  - q: "Does GrapheneOS run on Motorola phones yet?"
    a: "No. Motorola announced a partnership in March 2026 and the Signature 27 as the first phone with planned GrapheneOS support, but the official FAQ still lists Pixel phones only. Planned support is not live support."
  - q: "Will my banking app work on GrapheneOS?"
    a: "Most will, but not all. GrapheneOS passes the basic and device Play Integrity checks on Pixel hardware, not the strong check, which needs Google-signed hardware keys. Apps that demand strong integrity will refuse to run, so check the community compatibility list before switching."
---

On November 19, the team behind GrapheneOS went public with an accusation it had apparently been sitting on for a while: Google is trying to kill it. Not by competing with it, but by leaning on phone makers, by locking down the bootloader, and by pushing the Play Integrity checks that keep banking apps away from alternative operating systems.

Here is the short version, because the headline writes itself and the facts do not. Nothing has changed for Pixel owners yet. Google has announced no bootloader lock and has not responded to the accusation at all. What GrapheneOS published is a mix of a claim, some real evidence, and a prediction, and the honest way to read it is to keep those three in separate boxes.

## What GrapheneOS actually said

The accusation came as [a thread on the project's Mastodon account](https://grapheneos.social/@GrapheneOS/117645038299496084) on November 19, 2026. The opening post is blunt:

> "Google is sabotaging their OEM partners by making a growing number of features and updates exclusive to Pixels. At the same time, Google is trying to convince OEM partners not to support GrapheneOS or even bootloader unlocking. They're also trying to harm GrapheneOS directly."

A follow-up posted just after midnight UTC added the specific charge: "Google has been repeatedly reaching out to OEMs to question whether they're working with us and threaten them based on GMS licensing terms found to be illegal by multiple courts." GMS is Google Mobile Services, the bundle of Google apps and APIs that ships on nearly every Android phone sold outside China, and its licensing terms are the lever GrapheneOS says Google is pulling.

Then came the prediction, in the project's own words: "We expect Google will begin bootloader locking Pixels, continue heavily pushing the illegal Play Integrity API and trying to make forks of AOSP non-viable." The word illegal there is GrapheneOS's characterization, not a court finding about Play Integrity itself. The thread also draws a line inside Google: "Google's engineers are not the problem. Their business people are the problem." It ends with a call for help, asking the community for introductions to US Attorney General Todd Blanche and the Justice Department.

## Claim, evidence, and prediction are three different things

The three parts of the thread do not have the same footing, so here they are side by side.

| | What GrapheneOS says | What backs it up | What is missing |
| --- | --- | --- | --- |
| The claim | Google is contacting phone makers to ask if they work with GrapheneOS, then threatening them over GMS licensing | GrapheneOS's own account of the contacts | No OEM is named, no Google employee is named, no documents have been published |
| The legal framing | The GMS terms are illegal and courts have said so | The EU's top court upheld a 4.125 billion euro Android fine against Google on July 2, 2026 (case C-738/22 P) | That case was about pre-installation deals and bundling, not about threats to specific OEMs over GrapheneOS |
| The prediction | Google will start locking Pixel bootloaders | Nothing yet; it is an expectation about the future | Google has announced nothing, and no Pixel has been locked |

The middle row is the strongest card GrapheneOS holds and the easiest to overread. The Court of Justice of the European Union really did [dismiss Google's final appeal on July 2, 2026](https://curia.europa.eu/site/upload/docs/application/pdf/2026-07/cp260093en.pdf), confirming the 4.125 billion euro fine for abusing its dominance through Android licensing restrictions. That is a real judgment about real conduct. What it is not is proof that Google threatened a specific phone maker about GrapheneOS last month. Those are different claims, and the second one still rests on the project's word alone.

## Why the bootloader is the whole ballgame

A bootloader is the first code that runs when your phone starts, and it decides which operating system is allowed to boot. On a Pixel, you can unlock it, and that is the door GrapheneOS walks through.

The [install process](https://grapheneos.org/install/cli) shows why the door matters twice. First you enable OEM unlocking in Developer options, then you run `fastboot flashing unlock` and confirm on the phone, which wipes the device. You flash the GrapheneOS factory images, and then you lock the bootloader again with `fastboot flashing lock`. That second lock is the clever part: it flashes GrapheneOS's own verified boot key into the phone's secure element, so every boot after that checks the operating system against GrapheneOS's signature. The phone shows a yellow warning on boot with the key's SHA-256 hash, and tampered system files get caught before they can run.

Take away the unlock step and the whole chain collapses. There is no install, no relock, no verified boot, and no GrapheneOS. That is why the prediction lands so hard, and why it is also the part of the story that is still only a prediction.

## The Pixel-only problem

GrapheneOS has only ever officially run on Pixels, and that is the project's weak spot. Its own [FAQ](https://grapheneos.org/faq), rechecked today, lists production support for the Pixel 6a through the Pixel 10a, with the Pixel 6 and 6 Pro on extended support past their October 2026 end of life. It recommends a Pixel 8 or newer, which gets seven years of support and hardware memory tagging. No other brand appears anywhere in the list.

The escape hatch is Motorola. The company announced a long-term partnership with GrapheneOS at MWC in March 2026, and on November 5 it announced the Signature 27 as the first Motorola phone with planned GrapheneOS support. Planned is the word to underline: nobody can install GrapheneOS on a Signature 27 today, and nothing in the FAQ has changed. GrapheneOS itself says Motorola is working with it "within the rules set by Google," and that Motorola is not allowed to sell devices with GrapheneOS preinstalled at a large scale because of the GMS licensing terms. That is the project's account, and it fits the shape of the GMS licensing fight, but it is still their account.

## Play Integrity and the banking app squeeze

The second front in the thread is Play Integrity, the API apps use to ask Google whether a phone is running a real, certified Android build. It returns three verdicts: basic integrity, device integrity, and strong integrity. GrapheneOS passes the first two on Pixel hardware. It does not pass strong integrity, which needs Google-signed hardware keys, and it refuses to fake any of it. Its [usage guide](https://grapheneos.org/usage) says the same about the older SafetyNet checks: it passes basic integrity, fails the certification check, and does not try to get around it.

That honesty has a cost, and it is the one most users will actually feel. Banking apps increasingly demand the strongest verdict, and an app that demands it will refuse to run on GrapheneOS. The project has added a notification that tells you which apps are using Play Integrity, plus an option to block the API for apps that can run without it. Before switching, check the community banking app compatibility list; a bank that works for someone else on a Pixel 8 may not work for you on a different setup.

The pressure is not only coming from Google. GrapheneOS says EU countries are adopting Play Integrity in their own apps, and that talks with the European Commission about it went nowhere. Add Google's developer verification requirement for sideloaded apps, scheduled to go global in January 2027, and the walls around the official Android path keep getting higher from every direction.

## The direction of travel is real, even if the threat is not proven

None of this proves that Google threatened an OEM about GrapheneOS. But the trend the project is pointing at does not need its word to be visible. Samsung hid the OEM unlocking toggle on One UI 8 in July 2025, setting `androidboot.other.locked=1` on models outside the US too; American Samsung phones never had the toggle at all. Other vendors have tightened unlocking before that. The lever itself is old: in 2012, Google blocked Acer from shipping a phone running a rival Android fork, citing its anti-fragmentation agreements, and Acer backed down.

Google has not responded to the accusations. Android Authority says it contacted Google and Motorola for comment and neither had responded when its story was published, and no response has surfaced since. That silence is not evidence either way. It is just the current state of play.

## What Pixel owners should do now

If you already run GrapheneOS, do nothing. Your phone works exactly as it did on November 18, and no update has changed that.

If you are thinking about switching, the practical advice is boring and useful. Buy a Pixel that is not tied to a carrier, because carrier variants can have unlocking disabled and the carrier may not be able to turn it back on. Before you buy a used Pixel, check that unlocking is actually possible by running `adb shell getprop sys.oem_unlock_allowed` and looking for a return value of 1. And if you do install, follow the official guide and relock the bootloader when it tells you to; an unlocked phone with GrapheneOS on it is missing the verified boot protection that is half the point.

The argument will not be settled by a thread. It will be settled by documents, by regulators, or by the day a Pixel ships with a bootloader that cannot be unlocked. Until then, treat the accusation as an accusation, the court record as a court record, and the prediction as a prediction. For the other side of Android privacy, the settings on a stock phone already give away more than most people realize; see our earlier piece on [what your Android phone tracks](/posts/your-android-phone-is-tracking-everywhere-you-go/). If you want a privacy win that does not depend on your bootloader at all, [Hex](/posts/hex-brings-your-voice-to-your-device-a-dictation-app-that-never-touches-the-cloud/) keeps your voice dictation entirely on your device.

## Frequently asked questions

**Has Google locked Pixel bootloaders?**

No. As of November 22, 2026, Google has announced nothing and has not responded to the accusation. The locked bootloader is GrapheneOS's prediction, not a Google plan, and nothing has changed for Pixel owners yet.

**Can I still install GrapheneOS today?**

Yes. GrapheneOS officially supports the Pixel 6a through the Pixel 10a, with extended support for the Pixel 6 and 6 Pro. You unlock the bootloader, flash the factory images, and relock it to GrapheneOS keys for verified boot.

**Does GrapheneOS run on Motorola phones yet?**

No. Motorola announced a partnership in March 2026 and the Signature 27 as the first phone with planned GrapheneOS support, but the official FAQ still lists Pixel phones only. Planned support is not live support.

**Will my banking app work on GrapheneOS?**

Most will, but not all. GrapheneOS passes the basic and device Play Integrity checks on Pixel hardware, not the strong check, which needs Google-signed hardware keys. Apps that demand strong integrity will refuse to run, so check the community compatibility list before switching.
