---
title: "Meet Ladybird: The Browser Being Built From Scratch Just Hit Alpha"
date: 2026-11-25 08:38:00 +0700
categories: [Linux]
tags: [ladybird, browser, open-source, linux, macos, web-engine]
description: "Ladybird, the browser with an engine written entirely from scratch, just shipped its first alpha for macOS and Linux. It is not ready to be your daily browser, but it is absolutely worth installing."
author: jonas
image:
  path: /assets/img/posts/ladybird-alpha-lead.svg
  alt: "Ladybird alpha showing the Wikipedia article about Ladybird in its own from-scratch engine (Screenshot: Ladybird)"
og_image: /assets/og/meet-ladybird-the-browser-being-built-from-scratch-just-hit-alpha.png
faq:
  - q: "Is Ladybird ready to replace Chrome or Firefox?"
    a: "No. The alpha is a testing release: some sites will not work, the browser will crash sometimes, and the project makes no security promises yet. Keep your current browser as your daily driver and run Ladybird alongside it."
  - q: "What makes Ladybird different from Brave, Arc, or other new browsers?"
    a: "Those browsers all reuse an existing engine, almost always Chromium's Blink. Ladybird's engine is written from scratch: its HTML, CSS, DOM, layout, JavaScript, and WebAssembly implementations share no code with Blink, WebKit, or Gecko."
  - q: "Which platforms does the Ladybird alpha support?"
    a: "macOS on Apple Silicon (macOS 14.4 or later) and Linux (Flatpak, apt packages for Ubuntu 24.04, 26.04, and 26.10, rpm packages for Fedora 44 and 45, plus a standalone archive). A Windows version is planned for a later stage, and mobile is not a current focus."
  - q: "When will Ladybird reach beta and stable?"
    a: "The project's roadmap calls for a beta in 2027 and a stable release for general use in 2028. The alpha is a rolling channel that updates itself automatically, so it should improve fast between now and then."
---

On Monday, November 23, a browser you have probably never used became a browser you can finally download. Ladybird, the independent browser with an engine written entirely from scratch, [shipped its first public alpha](https://ladybird.org/posts/alpha) for macOS and Linux.

Here is the honest verdict up front. Do not switch to it. Do install it anyway, next to your real browser, and break things on purpose. That is literally what the team is asking for, and it is the fastest way a project like this gets better.

## A fourth engine, built the hard way

Every browser you have used in the last decade runs on one of three engines. Google's Blink powers Chrome, Edge, Brave, and most of the rest. Apple's WebKit powers Safari. Mozilla's Gecko powers Firefox. Everything else is a skin over one of those three.

Ladybird is none of them. Its engine is written from the ground up, not a fork. HTML, CSS, the DOM, layout, JavaScript, and WebAssembly are all implemented from scratch, [according to the project's release notes](https://github.com/LadybirdBrowser/ladybird/releases). It began as a small HTML viewer inside SerenityOS, a hobby operating system, and grew into a standalone project with a small full-time team.

The structure around it is just as unusual. Ladybird is run by a US nonprofit, the Ladybird Browser Initiative, and funded entirely by donations and sponsorships. The project says it takes no default search deals, no crypto tokens, and no other form of user monetization, and that sponsors get no say in the roadmap. Sponsors so far include Proton and Cloudflare. The team aims to keep 18 months of runway in the bank at all times.

That matters because the reason we have three engines is not that building one is impossible. It is that building one is ruinously expensive, and only giant companies with something else to sell have been willing to pay for it. A nonprofit trying it anyway is the interesting part of this story.

## The number that turned heads

A from-scratch engine is a nice idea. What made people take this alpha seriously is a test score.

Web Platform Tests is the shared test suite every browser engine measures itself against. In its [October 2026 update](https://ladybird.org/newsletter/2026-10-31/), Ladybird reported passing Safari Technology Preview on October 26, ending the month at 2,184,722 passing subtests, a gain of 75,650 in a single month. The counts it published for the end of October:

| Browser | WPT subtests passing |
|---|---|
| Chrome | 2,244,397 |
| Firefox | 2,189,315 |
| Ladybird | 2,184,722 |
| Safari Technology Preview | 2,172,990 |

Two details make that month stranger than the headline. Most of the gain landed in five days, from about 2.12 million subtests on October 22 to about 2.18 million on October 27. The team got there by pointing AI coding agents at the failing tests and asking them to fill in the missing functionality. October also brought a JavaScript JIT compiler and a new WebAssembly engine built on Cranelift, which the project says delivered a 7x speedup on the JetStream 3 WebAssembly benchmark.

Keep the score in proportion. Passing subtests is not the same as rendering every website correctly, and the team says so itself. But an engine that was a curiosity two years ago now sits within a few thousand subtests of Firefox on the industry's standard measuring stick. That is why the alpha arrived now and not a year from now.

## What you actually get in the alpha

The first build is tagged 2026.47.7, and lead developer Andreas Kling describes it as "modest, but functional." That is about right. You get tabs, browsing history, session restore, media playback, and a DevTools setup with Inspect Element and console autocomplete. Under the hood it is a real modern architecture: documents from different sites run in separate sandboxed renderer processes, and image decoding and network connections happen out of process, per site.

What you do not get is the stuff that makes a browser livable day to day. There are no extensions yet, and the project has not put a date on them. Some sites will not work. The browser will crash sometimes. And the team is blunt about the biggest gap: it makes no security promises for the alpha, and it invites security researchers to hack it and report what they find.

The download itself is small. The macOS build is a 71.8 MB disk image for Apple Silicon, requiring macOS 14.4 or later. Linux gets a Flatpak, apt packages for Ubuntu 24.04, 26.04, and 26.10, rpm packages for Fedora 44 and 45, and a standalone archive. The alpha is a rolling channel that updates itself automatically, except for the standalone Linux archive. A Windows version is planned for a later stage, and mobile is not a current focus.

## How to try it without regretting it

Trying an alpha browser is easy. Trying one safely takes about five minutes of discipline.

1. Download it from [ladybird.org](https://ladybird.org/) and install it alongside your current browser. Do not import anything you would miss.
2. Use it for casual browsing and for sites you are curious about. Keep banking, work logins, and anything sensitive in your mature browser until Ladybird hardens.
3. When a site breaks, report it from inside the browser. That button is the whole point of the alpha: every broken-site report tells the team what to fix next.
4. After a crash, read the crash report before you send it. Ladybird lets you review it first, and its privacy policy explains what it contains.
5. If you build websites, try yours in Ladybird. It supports WebDriver for automated testing and the Firefox DevTools protocol, so you can fold it into a test run instead of clicking around by hand.

That last group is who this alpha is really for. Web developers testing against a fourth engine is how the web stops being tested against one engine with three names.

## Should you care yet?

If you need a browser that just works, no. Wait for the beta in 2027, or the stable release the roadmap promises for 2028. Nothing about the alpha pretends otherwise.

If you care about the open web, or you build for it, yes. Browser engines have been stuck at three for so long that a fourth one showing up feels like spotting a new species. The difference is that this one you can download today, watch update itself every week, and help shape by reporting what breaks. Most software asks for your money or your data. This one just asks for your bug reports.

Install it as a second browser. Kick the tires. Then tell the team what fell off.

## Frequently asked questions

**Is Ladybird ready to replace Chrome or Firefox?**
No. The alpha is a testing release: some sites will not work, the browser will crash sometimes, and the project makes no security promises yet. Keep your current browser as your daily driver and run Ladybird alongside it.

**What makes Ladybird different from Brave, Arc, or other new browsers?**
Those browsers all reuse an existing engine, almost always Chromium's Blink. Ladybird's engine is written from scratch: its HTML, CSS, DOM, layout, JavaScript, and WebAssembly implementations share no code with Blink, WebKit, or Gecko.

**Which platforms does the Ladybird alpha support?**
macOS on Apple Silicon (macOS 14.4 or later) and Linux (Flatpak, apt packages for Ubuntu 24.04, 26.04, and 26.10, rpm packages for Fedora 44 and 45, plus a standalone archive). A Windows version is planned for a later stage, and mobile is not a current focus.

**When will Ladybird reach beta and stable?**
The project's roadmap calls for a beta in 2027 and a stable release for general use in 2028. The alpha is a rolling channel that updates itself automatically, so it should improve fast between now and then.
