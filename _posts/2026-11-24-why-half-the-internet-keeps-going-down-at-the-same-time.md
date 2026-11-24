---
title: "Why Half the Internet Keeps Going Down at the Same Time"
date: 2026-11-24 20:05:00 +0700
categories: [Networking]
tags: [cloud-outage, aws, azure, cloudflare, dns, internet-outage]
description: "One permissions change at Cloudflare, one DNS bug at AWS, and half the web went dark. The outages are not random, and hackers are not the main cause."
author: elena
image:
  path: /assets/img/posts/internet-outages-lead.svg
  alt: "Rows of server racks in the CERN data centre that runs the Worldwide LHC Computing Grid (Photo: Sashimi-b, CC BY-SA, via Wikimedia Commons)"
og_image: /assets/og/why-half-the-internet-keeps-going-down-at-the-same-time.png
faq:
  - q: "Was the November 2026 cluster of outages a cyberattack?"
    a: "Nothing in the public record points to one. The companies' own post-mortems blame software defects, configuration changes, and infrastructure failures, and US officials have said the failures were not a coordinated attack. AI makes it easier to find flaws, which cuts both ways, but the outages themselves were self-inflicted."
  - q: "Why does one company's outage take down so many unrelated sites?"
    a: "Because those sites are not really unrelated. They share the same few providers underneath: the same clouds for hosting, the same CDN for delivery, the same DNS for lookups. When a shared service breaks, every site built on it breaks at the same time, even if the sites have nothing else in common."
  - q: "How much of the internet runs on AWS, Azure, and Google Cloud?"
    a: "The three together took 61 percent of worldwide cloud infrastructure spending in the third quarter of 2026, according to Synergy Research Group: AWS at 26 percent, Microsoft at 19 percent, and Google Cloud at 16 percent. Cloudflare separately sits in front of roughly a fifth of all websites."
  - q: "What can I actually do when a big outage hits?"
    a: "Check the provider's status page before rebooting your router or reinstalling anything, keep local copies of the documents you cannot afford to lose access to, and avoid putting every login behind a single identity provider. You cannot fix the concentration yourself. You can stop one outage from locking you out of everything at once."
---

Earlier this month, Outlook stopped working for the better part of two days. Flights stopped moving when the FAA halted departures nationwide. A major bank's online services went dark. AWS had an incident of its own the same week. None of these were the same outage. That is the point.

Half the internet keeps going down at the same time because half the internet is the same few companies. Your email, your bank, your airline, and the apps on your phone mostly rent space in the same three clouds and pass through the same one or two networks on the way to you. When one of those breaks, it does not look like one company having a bad day. It looks like the internet broke.

## The week it happened again

The cluster landed in the second week of November 2026. Microsoft 365 went down on November 12 and stayed broken into the next day, with Outlook, Teams, and SharePoint all affected. The FAA ordered a nationwide ground stop around November 13 that held departures for hours. JPMorgan Chase customers hit a banking outage on November 16. AWS reported an infrastructure incident on November 15.

The Verge summed up the mood on November 22: we have not seen the last of the major tech outages. The director of national intelligence told CNN to expect heavy investment in upgrades and cybersecurity, and to expect bumps in the road whenever technology takes a step change. Microsoft president Brad Smith was blunter on CBS. The whole information infrastructure of the world is being upgraded right now, he said, and "this isn't the type of thing that just gets done in a couple of weeks."

Both men were describing the same uncomfortable fact. The outages are not a freak run of bad luck. They are what a system built this way does.

## Three companies run most of the internet

Start with the numbers. In the third quarter of 2026, worldwide spending on cloud infrastructure services hit $167.7 billion. AWS took 26 percent of it, Microsoft 19 percent, and Google Cloud 16 percent, [according to Synergy Research Group](https://www.crn.com/news/cloud/2026/cloud-market-share-q3-google-cloud-gains-as-aws-loses-ground-anthropic-and-spacex-crack-into-top-10). The big three together hold 61 percent of the market. The rest is split among everyone else.

Then add the layer most people never see. Cloudflare sits in front of roughly a fifth of all websites, about 21 percent according to W3Techs, acting as a reverse proxy, a DNS provider, and a security shield. When a site uses Cloudflare, your browser does not talk to the site. It talks to Cloudflare, and Cloudflare talks to the site.

So the typical website you visit runs on one of three clouds, behind one of a handful of CDNs, and its name resolves through one of a handful of DNS providers. That stack is efficient and cheap, which is why everyone uses it. It is also a set of single points of failure wearing a trench coat. A failure at any one layer reaches every customer of that layer at once.

## How a tiny change takes down a continent of websites

Here is the part that surprises people. The big outages are almost never caused by something dramatic. They are caused by small, routine changes that propagate everywhere in minutes, because that is what these systems are designed to do.

Take Cloudflare on November 18, 2025. An engineer made a routine change to the permissions on a database cluster. That change made a metadata query start returning every column twice. The query fed a configuration file for Cloudflare's Bot Management system, so the file doubled in size, past a hard limit of 200 features. The new proxy software hit that limit and panicked. Core traffic started failing at 11:20 UTC and was largely flowing again by 14:30, with everything normal by 17:06. Cloudflare called it its worst outage since 2019, and [said plainly that no attack was involved](https://blog.cloudflare.com/18-november-2025-outage). ChatGPT, Canva, and parts of AWS went down with it, because they sit behind the same network.

AWS had its own version a month earlier. On October 19 and 20, 2025, a latent race condition in DynamoDB's automated DNS management left the service's regional endpoint in Northern Virginia with an empty DNS record. Nothing could resolve the name, so nothing could connect. The event ran about 15 hours, and the damage spread: new EC2 instances failed to launch, and Network Load Balancers started failing health checks. Snapchat, Fortnite, Roblox, and Slack were among the services users noticed going down. The root cause was two automation components disagreeing about which plan was current. A DNS record, the most boring object in computing, took down a region. [ThousandEyes' analysis](https://www.thousandeyes.com/blog/aws-outage-analysis-october-20-2025) walks through the cascade in detail.

Azure's turn came on October 29, 2025, when its Front Door service went down for about eight and a half hours, taking Microsoft 365, the Azure portal, and many customer sites with it. One tracker counted 19 major outages involving AWS, Azure, Google Cloud, or Cloudflare in 2026 through mid-November alone.

Notice the pattern. Nobody attacked anything. A permissions change, a race condition, a bad rollout. These systems are so large and so automated that a small mistake does not stay small. The automation that makes them fast is the same automation that spreads the mistake to every machine on the network before a human can reach for the brakes.

## It is usually not hackers

Every time a cluster like this hits, the first theory is a coordinated cyberattack. It is a satisfying theory. It is also, so far, wrong. The post-mortems keep saying the same thing: software defect, configuration change, power failure, heat. Cloudflare's own blog post on the November 2025 outage opens by ruling out an attack entirely.

That does not mean attackers are irrelevant. Smith's warning to CBS was that AI makes it easier to find flaws in code, and that knowledge can go to whoever finds it first, the people patching or the people breaking in. The infrastructure is being upgraded in a hurry, partly because of AI, and rushed upgrades of aging systems are exactly when mistakes slip through. The threat is real. It just is not what took your email down last week. We did that to ourselves, with a config change and a deploy.

There is a second, quieter reason the cluster felt so big. Outages used to be local. Your bank's servers went down and your bank was down. Now your bank runs on the same cloud as your email, your airline, and your group chat. The blast radius of one mistake is now measured in other companies' uptime, not just your own.

## What you can actually do about it

The honest answer starts with what you cannot do. You cannot diversify away from the big three by yourself. Moving your photos onto a smaller host just trades one single point of failure for a smaller, less reliable one. Multi-cloud is a real answer for companies with engineering teams. It is not a weekend project for one person.

What you can do is stop one outage from locking you out of everything at once.

Keep local copies of the documents you would be stuck without: boarding passes, tickets, contracts, the phone numbers you would need if your contacts app went dark. Cloud sync is a backup until the cloud is the thing that is down.

Do not put every login behind a single identity provider. If your Microsoft account is the key to your email, your files, and your work apps, one Microsoft outage locks all three doors at the same time. A second sign-in method, or a password manager that works offline, is worth more than it looks like on a calm day.

When something big stops working, check the provider's status page before you touch your own setup. Rebooting your router, reinstalling an app, or resetting a password during someone else's outage only adds a second problem. The status pages are boring and that is their virtue: Cloudflare, AWS, and Microsoft all publish them, and they will tell you it is not you.

These companies do publish real post-mortems, and they do fix the specific bug. Cloudflare now validates its own generated configuration files like user input. AWS disabled the DynamoDB DNS automation worldwide until it fixed the race condition. The system gets a little more robust each time. It also gets a little bigger and a little more concentrated each time, which is why the next outage is a matter of when, not if.

The internet did not get more fragile because someone is attacking it. It got more fragile because it got more centralized, and the machinery that makes it fast also makes its mistakes instant and total. Expect more of this. Keep a local copy of the things that matter. And when half the web goes dark at once, remember it was probably one permissions change, somewhere, made by someone having a normal Tuesday.

## Frequently asked questions

**Was the November 2026 cluster of outages a cyberattack?**
Nothing in the public record points to one. The companies' own post-mortems blame software defects, configuration changes, and infrastructure failures, and US officials have said the failures were not a coordinated attack. AI makes it easier to find flaws, which cuts both ways, but the outages themselves were self-inflicted.

**Why does one company's outage take down so many unrelated sites?**
Because those sites are not really unrelated. They share the same few providers underneath: the same clouds for hosting, the same CDN for delivery, the same DNS for lookups. When a shared service breaks, every site built on it breaks at the same time, even if the sites have nothing else in common.

**How much of the internet runs on AWS, Azure, and Google Cloud?**
The three together took 61 percent of worldwide cloud infrastructure spending in the third quarter of 2026, according to Synergy Research Group: AWS at 26 percent, Microsoft at 19 percent, and Google Cloud at 16 percent. Cloudflare separately sits in front of roughly a fifth of all websites.

**What can I actually do when a big outage hits?**
Check the provider's status page before rebooting your router or reinstalling anything, keep local copies of the documents you cannot afford to lose access to, and avoid putting every login behind a single identity provider. You cannot fix the concentration yourself. You can stop one outage from locking you out of everything at once.
