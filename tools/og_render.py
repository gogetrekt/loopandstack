#!/usr/bin/env python3
"""Render branded OG share cards (1200x630 PNG) for loop and stack.
Called by _plugins/og_images.rb during the Jekyll build with a JSON payload:
{"posts": [{"slug": ..., "title": ...}], "out": "<dir>"}
Writes og-default.png plus one <slug>.png per post into the output dir.
Fails soft: any error exits non-zero and the build continues without images.
"""
import json, os, subprocess, sys, textwrap, urllib.request

def ensure_pillow():
    try:
        import PIL  # noqa
        return
    except ImportError:
        subprocess.run([sys.executable, "-m", "pip", "install", "--quiet", "pillow"], check=False)
        import PIL  # noqa

ensure_pillow()
from PIL import Image, ImageDraw, ImageFont

BG = (26, 27, 38); GREEN = (158, 206, 106); WHITE = (240, 240, 245); MUTED = (154, 165, 206)

def mark(d, x, y, s, color):
    u = s / 807.0
    def R(rx, ry, rw, rh): d.rectangle([x + rx * u, y + ry * u, x + (rx + rw) * u, y + (ry + rh) * u], fill=color)
    def C(cx, cy, r): d.ellipse([x + (cx - r) * u, y + (cy - r) * u, x + (cx + r) * u, y + (cy + r) * u], fill=color)
    R(348, 0, 55, 247); R(348, 560, 55, 247); R(0, 388, 247, 51); R(500, 388, 247, 51)
    C(175.5, 191.5, 35.5); C(555.5, 191.5, 35.5); C(195.5, 615.5, 35.5); C(555.5, 615.5, 35.5)

def load_vt323(size):
    path = "/tmp/VT323-Regular.ttf"
    if not os.path.exists(path):
        try:
            urllib.request.urlretrieve("https://github.com/google/fonts/raw/main/ofl/vt323/VT323-Regular.ttf", path)
        except Exception:
            path = None
    if path and os.path.exists(path):
        return ImageFont.truetype(path, size)
    return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size)

def bold(size): return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size)
def reg(size): return ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", size)

def base():
    img = Image.new("RGB", (1200, 630), BG)
    d = ImageDraw.Draw(img)
    d.rectangle([0, 0, 1200, 10], fill=GREEN)
    return img, d

def main():
    payload = json.load(open(sys.argv[1]))
    out = payload["out"]
    os.makedirs(out, exist_ok=True)
    # default brand card
    img, d = base()
    mark(d, 90, 165, 300, WHITE)
    d.text((420, 268), "loop and stack", font=load_vt323(96), fill=WHITE)
    d.text((424, 366), "all about the tools that power modern tech", font=reg(33), fill=MUTED)
    img.save(os.path.join(out, "og-default.png"))
    # per-post cards
    for post in payload["posts"]:
        slug, title = post["slug"], post["title"]
        if not slug or not title:
            continue
        img, d = base()
        mark(d, 70, 60, 120, WHITE)
        d.text((190, 84), "loop and stack", font=load_vt323(64), fill=WHITE)
        y = 250
        for ln in textwrap.wrap(title, width=34)[:3]:
            d.text((90, y), ln, font=bold(54), fill=WHITE)
            y += 68
        d.text((90, 545), "loopandstack.tech", font=reg(26), fill=MUTED)
        img.save(os.path.join(out, slug + ".png"))
    print("og_render: wrote cards to", out)

if __name__ == "__main__":
    main()
