---
title: "Run Local AI on Your Own PC: Qwen, Unsloth, and What Actually Works"
date: 2026-11-24 08:38:00 +0700
categories: [AI Tools]
tags: [qwen, unsloth, local-ai, ollama, llama-cpp, llm]
description: "A 27-billion-parameter model now runs on a single mid-range graphics card, and setup takes one command. Here is which Qwen model fits your hardware, how to run it, and when local still loses to the cloud."
author: daniel
image:
  path: /assets/img/posts/qwen-unsloth-local-ai-lead.svg
  alt: "A gaming PC with a GeForce RTX graphics card, the hardware that runs local AI models (Photo: MoreThanTech, CC BY 3.0, via Wikimedia Commons)"
og_image: /assets/og/run-local-ai-on-your-pc-qwen-unsloth.png
faq:
  - q: "How much VRAM do I need to run Qwen locally?"
    a: "8 GB is enough for Qwen3-8B at 4-bit quantization, which needs about 5 GB for the weights. Qwen3.8-27B needs 16 to 19 GB at 4-bit, so a 16 GB card works with modest context, and a 24 GB card is comfortable. On a Mac, 24 GB of unified memory is the floor for the 27B model."
  - q: "Is running Qwen locally actually free?"
    a: "Yes, after the hardware. The weights are Apache 2.0 open source, Ollama and llama.cpp cost nothing, and there is no per-token bill. You pay in electricity and in the download, which is 5 GB for Qwen3-8B and about 18 GB for the Ollama build of Qwen3.8-27B."
  - q: "Which is better for local AI, Ollama or llama.cpp?"
    a: "Ollama if you want it running in five minutes. It handles downloads, quantization, and the API server for you. llama.cpp if you want to pick the exact quantization file, control how many layers sit on the GPU, or run a model Ollama does not package yet."
  - q: "Does local AI beat ChatGPT or Claude?"
    a: "Not at raw capability. A 27B local model is genuinely good at coding, drafting, and everyday questions, but it will not match a frontier cloud model on hard reasoning. Local wins on privacy, offline use, and cost: your prompts never leave the machine and there is no monthly bill."
---

A year ago, running a good AI model on your own PC meant settling. The models that fit on a normal graphics card were the small ones, and the small ones were noticeably worse than the chatbots you pay $20 a month for. That tradeoff just flipped.

Qwen's 27-billion-parameter Qwen3.8-27B runs on a single 16 GB card, and with Unsloth's new Dynamic V3.1 quants it keeps far more of its quality while doing it. Setup is one command if you use Ollama. This is the guide to doing it right, and to knowing when local still loses to the cloud.

## Why this month is different

Two things changed. First, Qwen shipped Qwen3.8-27B in August 2026: a dense 27B model with vision, a 262,144-token native context window, and configurable reasoning, released under the Apache 2.0 license. It is the first open 27B-class model with native image and video input, and it is built for agentic coding, the kind of long, tool-using work where small models used to fall apart.

Second, Unsloth re-quantized it. On November 11, 2026, Unsloth released Dynamic V3.1 GGUF builds of Qwen3.8-27B and reported a 5 to 10 percent accuracy improvement over standard quants at the same file size, measured on benchmarks including Terminal Bench and DeepSWE. That is the vendor's own number, not an independent test, so take the exact percentage with a grain of salt. But the direction matters: the quant file you download now matters as much as the model you pick.

Put together, the model worth running is no longer the tiny one that fits. It is a genuinely capable one that fits.

## Pick the model that fits your card

VRAM is the whole decision. Quantization shrinks the weights, and 4-bit is the sweet spot for almost everyone: roughly half the quality loss of 2-bit for a file you can still fit. These are the three picks that cover nearly every PC.

| Model | Weights at 4-bit | You need | Good for |
| --- | --- | --- | --- |
| Qwen3-8B | ~5 GB | 8 GB VRAM, or 16 GB RAM CPU-only | Chat, drafting, light coding |
| Qwen3.8-27B | ~16.6 GB | 16-19 GB VRAM, or a 24 GB Mac | Coding agents, long documents, vision |
| Qwen3-Coder-30B-A3B | ~18.7 GB | 24 GB VRAM | Serious coding, big repos |

Qwen3-8B is the older model, from April 2025, with a 32,768-token native context. It is still the right pick if your card has 8 or 12 GB, because it runs fast and the 4-bit version barely loses anything. Qwen3.8-27B is the upgrade path when you have the VRAM. The coder model is a mixture-of-experts design: 30.5 billion parameters in total, but only about 3.3 billion activate per token, which is why it fits on one card at all.

One warning that bites everyone once: the file size is not the memory size. A long context window eats VRAM through the KV cache, and Qwen3.8-27B at its full 256K context can add more than 10 GB on top of the weights. If you are tight on memory, cap the context. You will use 32K far more often than you think.

## The easy way: Ollama

Ollama is the right starting point for almost everyone. It installs in minutes, downloads the model for you, and exposes an OpenAI-compatible API on your own machine, so tools like coding assistants can talk to it without any cloud account.

1. Install Ollama from [ollama.com](https://ollama.com) for Windows, macOS, or Linux.
2. Pull and run the model you picked:
   ```bash
   ollama run qwen3.8
   ```
   That downloads the roughly 18 GB build and drops you into a chat. For the smaller model, swap in `ollama run qwen3:8b`.
3. Chat in the terminal, or point any OpenAI-compatible client at `http://localhost:11434/v1`. That endpoint is how you wire it into a coding tool or a local chat UI.

One honest caveat: Ollama's Qwen3.8 build is about 18 GB, which is slightly more than a 16 GB card holds. On a 16 GB card it will still run, but some layers spill to system RAM and speed drops. If you are on 16 GB and want a clean fit, use the llama.cpp route below with the smaller quant file instead.

## The control freak way: llama.cpp and Unsloth GGUFs

llama.cpp is more work and more control. You pick the exact quantization file, decide how many layers live on the GPU, and run models Ollama does not package. The files you want live in Unsloth's `unsloth/Qwen3.8-27B-GGUF` repository on Hugging Face, built with the Dynamic V3.1 recipe.

For a 16 GB card, grab `UD-IQ4_XS`, the 14.3 GB file. It is the 4-bit tier sized for your card with room left for context. If you have 24 GB, take `UD-Q4_K_M` at 16.6 GB, the conventional 4-bit pick. Then serve it:

```bash
llama-server -hf unsloth/Qwen3.8-27B-GGUF:UD-IQ4_XS -c 32768
```

The `-c 32768` flag caps the context at 32K tokens, which keeps the KV cache from eating the VRAM you just saved. Raise it only if you actually paste long documents into the model.

This is also the route for CPU-only machines. llama.cpp runs Qwen3-8B at 4-bit on a 16 GB RAM box with no GPU at all, at roughly 5 to 15 tokens per second. That is slow enough to notice and fast enough to use for short answers.

## Three settings that decide whether it feels smart

Getting the model running is the easy half. Qwen3.8 is a hybrid thinking model, and its defaults are tuned for benchmark scores, not for your patience.

First, reasoning effort. The stock model defaults to extra-high thinking effort, which means long internal reasoning traces before it answers anything. If your replies feel slow and overthought, turn the effort down to medium. In Ollama you can do this per session; in llama.cpp it is a chat template setting. Medium is the model's native default and the right starting point for everyday use.

Second, sampling. For thinking mode, Unsloth recommends temperature 1.0, top_p 0.95, top_k 20, and min_p 0. Do not use greedy decoding (temperature 0) in thinking mode: on Qwen3 models it can make the model loop on itself. For plain non-thinking chat, temperature 0.7 with top_p 0.8 is the calmer choice.

Third, context. A 256K window sounds like freedom until you watch a long conversation slow to a crawl. Most work fits in 32K. Set the context to what your session actually needs and your card will thank you.

## When local wins, and when it doesn't

Local wins on three things no cloud plan can match. Your prompts never leave the machine, which matters the moment you paste proprietary code or private documents. It works offline, on a plane or a flaky connection. And it costs nothing per token: after the hardware you already own, a thousand long coding sessions cost the same as one.

It loses on raw capability and on convenience. A 27B model is genuinely good at coding, drafting, and everyday questions, but it will not match a frontier cloud model on hard reasoning or the biggest agentic jobs. It also will not set itself up: you are the IT department now, and a bad quant file or a wrong sampling setting is your problem to debug.

So here is the honest verdict. If you have a 16 GB card or better and you write code or handle private text, install Ollama and run Qwen3.8-27B today. The five minutes it takes will pay for themselves the first time you refactor something you would never paste into a website. If your card has 8 GB, Qwen3-8B is still a capable daily driver. And if you just want the smartest answer to a hard question with zero setup, keep paying the $20. Local AI stopped being a compromise this month. It did not stop being a tradeoff.

## Frequently asked questions

**How much VRAM do I need to run Qwen locally?**
8 GB is enough for Qwen3-8B at 4-bit quantization, which needs about 5 GB for the weights. Qwen3.8-27B needs 16 to 19 GB at 4-bit, so a 16 GB card works with modest context, and a 24 GB card is comfortable. On a Mac, 24 GB of unified memory is the floor for the 27B model.

**Is running Qwen locally actually free?**
Yes, after the hardware. The weights are Apache 2.0 open source, Ollama and llama.cpp cost nothing, and there is no per-token bill. You pay in electricity and in the download, which is 5 GB for Qwen3-8B and about 18 GB for the Ollama build of Qwen3.8-27B.

**Which is better for local AI, Ollama or llama.cpp?**
Ollama if you want it running in five minutes. It handles downloads, quantization, and the API server for you. llama.cpp if you want to pick the exact quantization file, control how many layers sit on the GPU, or run a model Ollama does not package yet.

**Does local AI beat ChatGPT or Claude?**
Not at raw capability. A 27B local model is genuinely good at coding, drafting, and everyday questions, but it will not match a frontier cloud model on hard reasoning. Local wins on privacy, offline use, and cost: your prompts never leave the machine and there is no monthly bill.
