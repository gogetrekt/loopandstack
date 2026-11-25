---
title: "Azure APIM Flaw: Check and Rotate Your Keys Now"
date: 2026-11-25 15:12:00 +0700
categories: [Dev Tools]
tags: [azure, api-management, apim, security, key-rotation, microsoft]
description: "Microsoft closed an Azure API Management flaw on November 19, but credentials stolen before then still work. If you run APIM Classic, rotate your keys now."
author: priya
image:
  path: /assets/img/posts/azure-apim-flaw-lead.svg
  alt: "Rows of server racks in a data center aisle (Photo: Midas)"
og_image: /assets/og/azure-apim-flaw-check-and-rotate-your-keys-now.png
faq:
  - q: "Am I affected if I use Azure API Management v2?"
    a: "No. Microsoft says the flaw hit the Classic tiers only: Developer, Basic, Standard, and Premium. The Consumption tier of Classic and all v2 tiers were not affected."
  - q: "Did Microsoft fix the flaw, or do I still need to do something?"
    a: "Microsoft closed the unauthorized access path on November 19, one day after finding the flaw. But the fix does not invalidate credentials that were taken before then, so you still need to rotate every secret your Classic instances hold."
  - q: "What exactly should I rotate?"
    a: "Subscription keys, secrets stored in named values, backend credentials, OAuth 2.0 and OpenID Connect client secrets, logger connection strings, credentials written directly into policies, and the tenant access keys used by the direct management API."
  - q: "How do I know if my instance is patched?"
    a: "Open https://<your-gateway-hostname>/internal-status-0123456789abcdef and read the RuntimeVersion line. Version 0.52.x is patched at build 31936 or higher, and 0.53.x at build 31938 or higher. If yours is below that, contact Microsoft."
---

If you run Azure API Management on a Classic tier, rotate your keys today. Microsoft closed the hole behind this flaw on November 19, one day after finding it. That was the fast part. The slow part is yours: every credential an attacker copied out before the fix still works right now, and Microsoft's fix does not switch any of them off.

That is the whole story in one sentence. The rest of this article is how to check whether you are affected and how to rotate everything properly, because doing it in the wrong order can break your APIs or leave the old keys live.

## What happened

Microsoft found the flaw on November 18 and closed the unauthorized access path the next day. The timeline since then:

| Date | What happened |
|---|---|
| Nov 17 | Equinor discloses an ongoing cyberattack on some of its IT systems |
| Nov 18 | Microsoft identifies the APIM flaw; Skagerak Energi reports an attempted attack |
| Nov 19 | Microsoft closes the unauthorized access path |
| Nov 20 | Norway's NSM publishes its advisory; Equinor says the attack is stopped |
| Nov 21 | Microsoft publishes a credential rotation guide |
| Nov 23 | NSM updates its guidance; the flaw becomes public knowledge |

The flaw itself is an access control gap. On Classic tier instances that were not configured to Microsoft's recommended security practices, an unauthorized party could reach certain management functionality and perform administrative operations, including reading the secrets stored in the service. Microsoft rated the flaw critical.

Here is the part worth pausing on. There is no CVE number for this flaw, and Microsoft never published a public advisory about it. Affected customers got a private Azure Service Health notice, tracking ID MZK9-GH0. The public record exists because BleepingComputer and The Register saw that notice, and because Norway's National Security Authority (NSM) went public with its own guidance. The flaw was first detected by Norway's energy sector, Equinor in particular, not by Microsoft. The fix was fast. The telling was not.

This also landed days after Microsoft confirmed a separate breach involving its Entra Connect Health service, where attackers stole tenant configuration information and administrator email addresses. It has been a rough week for Microsoft's cloud.

## What the flaw exposed

[Microsoft's advisory](https://www.bleepingcomputer.com/news/security/microsoft-azure-flaw-exploited-to-steal-customers-api-credentials/) lists four kinds of credentials that may have been exposed:

- **Secrets stored in named values.** Often the keys to your backend services: database connection strings, third-party API tokens, shared secrets your policies inject into requests.
- **Client secrets for identity providers and OpenID Connect providers.** With one of these, an attacker can interfere with your sign-in flows.
- **Subscription keys.** The keys your API consumers use. With one, an attacker calls your APIs as a legitimate customer.
- **Tokens used to call the direct management APIs.** Administrative tokens for the instance itself.

Microsoft's own warning is blunt: these credentials could let attackers reach additional applications, services, or backend systems, depending on their permissions. An API gateway is a key cabinet. This flaw handed over the cabinet.

## Are you affected?

Check three things.

**Your tier.** The flaw hit the Classic tiers: Developer, Basic, Standard, and Premium. The Consumption tier of Classic and all APIM v2 tiers were not affected. If you are on v2, you can stop reading and go do something nicer with your afternoon.

**Your configuration.** Microsoft ties exposure to instances that were not configured to its recommended security practices, including instances that stored secrets directly in APIM instead of referencing Azure Key Vault. If your named values point at Key Vault, the blast radius is smaller. If secrets live as plain values inside APIM, assume they are gone.

**Your runtime version.** [NSM's guidance](https://nsm.no/aktuelt/nsm-deler-tiltak-mot-sarbarhet-i-azure-api-management) tells you to open `https://<your-gateway-hostname>/internal-status-0123456789abcdef` and read the RuntimeVersion line. Version 0.52.x is patched at build 31936 or higher, and 0.53.x at build 31938 or higher. Anything below that is still vulnerable, and NSM says to contact Microsoft directly.

One wrinkle: Microsoft says its November 19 remediation was fully deployed to Microsoft-hosted instances and needed no customer action. NSM still tells customers to verify their runtime version, and Microsoft has not explained the gap. Check anyway. It costs a minute.

## Rotate everything, in this order

Microsoft published a [rotation guide](https://techcommunity.microsoft.com/blog/integrationsonazureblog/rotating-credentials-in-azure-api-management/4575478) on November 21. The order matters, so follow it:

1. **Inventory first.** List every APIM instance you own and flag the Classic ones. Then list every secret each one holds: subscription keys, named values (check which are Key Vault backed and which are plain stored values), backend credentials, OAuth 2.0 and OpenID Connect client secrets, logger connection strings, credentials written directly into policies, and tenant access keys. The guide has Azure CLI and PowerShell commands for each list.
2. **Create the replacement at the issuer.** Make the new secret at the backend service or identity provider before you touch APIM. This is the step people skip, and it is the one that matters most: updating the value in API Management does not revoke the old credential at its issuer. Change it in APIM alone and the stolen key still works everywhere else.
3. **Update APIM with the new secret.** For subscription keys, use the two-key dance: move callers to the secondary key, regenerate the primary, test it, move callers back, then regenerate the secondary. For named values backed by Key Vault, store the replacement in Key Vault and refresh; for plain stored values, replace the value and consider moving the secret to Key Vault while you are there. For backend credentials, stage the replacement at the backend, update APIM, and test before revoking the old one.
4. **Test your APIs.** Confirm requests succeed with the new credentials before you revoke anything. Revoking first and testing second is how a security fix becomes an outage.
5. **Revoke the old secret.** Delete the old client secret on the Entra app registration, regenerate the tenant access keys, and remove the old values from APIM. Only now is the stolen credential dead.

While you are in there, move any secret still stored as a plain value in APIM into a Key Vault reference. Secrets that live in the gateway get stolen with the gateway.

## Then hunt in the logs

Rotation stops future abuse. It does not tell you whether the old keys were already used. Microsoft's advice is to investigate suspicious activity in every system those credentials can reach, and cloud security researcher Anders Kristiansen has published hunting queries for exactly this.

In AzureActivity, look for secret-read operations: `namedValues/listValue`, `subscriptions/listSecrets`, `tenant/listSecrets`, and `identityProviders/listSecrets`, plus writes to policies, named values, identity providers, and users by callers or IP addresses you do not recognize. In the gateway logs, look for subscription IDs you have not seen in the last 30 days and requests with tracing enabled. Then check the logs of the backend systems behind APIM: a stolen subscription key is most useful against the API it belongs to, and that is where the use will show up.

## The quiet part

Cloud flaws that hand over the keys are becoming a pattern. Last week it was a cloud flaw in GL.iNet routers being actively exploited, and we wrote about [checking yours](/posts/own-a-gl-inet-router-a-cloud-flaw-is-being-exploited-check-yours-now/) then. The shape is the same every time: a service that holds other people's credentials turns out to hold them loosely, and the customers find out late.

None of that changes what you do today. Rotate the keys. But it should change where you keep them next time, and it should change how much you trust a vendor's silence. Microsoft fixed this in a day and told almost nobody. Equinor and Norway's NSM did the telling. If your security plan assumes the vendor will always be the one to raise the alarm, this incident is your evidence that it will not.

## Frequently asked questions

**Am I affected if I use Azure API Management v2?**

No. Microsoft says the flaw hit the Classic tiers only: Developer, Basic, Standard, and Premium. The Consumption tier of Classic and all v2 tiers were not affected.

**Did Microsoft fix the flaw, or do I still need to do something?**

Microsoft closed the unauthorized access path on November 19, one day after finding the flaw. But the fix does not invalidate credentials that were taken before then, so you still need to rotate every secret your Classic instances hold.

**What exactly should I rotate?**

Subscription keys, secrets stored in named values, backend credentials, OAuth 2.0 and OpenID Connect client secrets, logger connection strings, credentials written directly into policies, and the tenant access keys used by the direct management API.

**How do I know if my instance is patched?**

Open https://<your-gateway-hostname>/internal-status-0123456789abcdef and read the RuntimeVersion line. Version 0.52.x is patched at build 31936 or higher, and 0.53.x at build 31938 or higher. If yours is below that, contact Microsoft.
