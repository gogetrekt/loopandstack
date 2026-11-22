# frozen_string_literal: true

require "chunky_png"
require_relative "og_font"

# Pure-Ruby OG share-card renderer for loop and stack. Draws 1200x630 PNG
# cards with the brand mark and VT323 pixel type (glyphs in og_font.rb).
# Used by _plugins/og_images.rb during the site build.
module LasOg
  BG = ChunkyPNG::Color.rgb(26, 27, 38)
  GREEN = ChunkyPNG::Color.rgb(158, 206, 106)
  WHITE = ChunkyPNG::Color.rgb(240, 240, 245)
  MUTED = ChunkyPNG::Color.rgb(154, 165, 206)
  W = 1200
  H = 630

  module_function

  def fill_rect(img, x, y, w, h, color)
    img.rect(x.round, y.round, (x + w).round - 1, (y + h).round - 1, color, color)
  end

  def fill_circle(img, cx, cy, r, color)
    img.circle(cx.round, cy.round, r.round, color, color)
  end

  # The asterisk brand mark, geometry measured from the original logo.
  def mark(img, x, y, size, color)
    u = size / 807.0
    fill_rect(img, x + 348 * u, y, 55 * u, 247 * u, color)
    fill_rect(img, x + 348 * u, y + 560 * u, 55 * u, 247 * u, color)
    fill_rect(img, x, y + 388 * u, 247 * u, 51 * u, color)
    fill_rect(img, x + 500 * u, y + 388 * u, 247 * u, 51 * u, color)
    fill_circle(img, x + 175.5 * u, y + 191.5 * u, 35.5 * u, color)
    fill_circle(img, x + 555.5 * u, y + 191.5 * u, 35.5 * u, color)
    fill_circle(img, x + 195.5 * u, y + 615.5 * u, 35.5 * u, color)
    fill_circle(img, x + 555.5 * u, y + 615.5 * u, 35.5 * u, color)
  end

  def draw_text(img, x, y, str, scale, color)
    str.each_char.with_index do |ch, i|
      glyph = OgFont::GLYPHS[ch]
      next if glyph.nil?

      gx = x + i * 16 * scale
      glyph.each_with_index do |row_hex, r|
        bits = row_hex.to_i(16)
        next if bits.zero?

        16.times do |c|
          next if (bits >> (15 - c)) & 1 == 0

          px = gx + c * scale
          py = y + r * scale
          if scale == 1
            img[px, py] = color
          else
            img.rect(px, py, px + scale - 1, py + scale - 1, color, color)
          end
        end
      end
    end
  end

  def wrap(text, max_chars)
    lines = []
    line = +""
    text.split(/\s+/).each do |word|
      if line.empty?
        line = word.dup
      elsif line.length + 1 + word.length <= max_chars
        line << " " << word
      else
        lines << line
        line = word.dup
      end
      while line.length > max_chars
        lines << line[0, max_chars]
        line = line[max_chars..] || +""
      end
    end
    lines << line unless line.empty?
    lines
  end

  def base_canvas
    img = ChunkyPNG::Image.new(W, H, BG)
    fill_rect(img, 0, 0, W, 10, GREEN)
    img
  end

  def default_card(path)
    img = base_canvas
    mark(img, 70, 150, 250, WHITE)
    draw_text(img, 354, 178, "loop and stack", 3, WHITE)
    draw_text(img, 358, 330, "all about the tools", 2, MUTED)
    draw_text(img, 358, 410, "that power modern tech", 2, MUTED)
    img.save(path)
  end

  # WhatsApp center-crops the 1200x630 card to about 3.3:1 in link
  # previews, so only the band y 133-497 survives (measured from the
  # user's own screenshots, 2026-11-22). All content must live inside
  # y 150-495: compact header on top, title block below it, footer only
  # when a short title leaves room. An earlier layout targeting a
  # 2.85:1 crop still got its wordmark shaved on the user's phone.
  def post_card(path, title)
    img = base_canvas
    mark(img, 70, 160, 76, WHITE)
    draw_text(img, 156, 158, "loop and stack", 2, WHITE)
    lines = wrap(title, 31)
    if lines.length > 4
      lines = lines[0, 4]
      lines[3] = lines[3][0, 30].rstrip + "\u2026"
    end
    case lines.length
    when 1..2
      step = 88
      block_h = (lines.length - 1) * step + 80
      start_y = 252 + (480 - 252 - block_h) / 2
      lines.each_with_index do |ln, i|
        draw_text(img, 90, start_y + i * step, ln, 2, WHITE)
      end
      draw_text(img, 90, 456, "loopandstack.tech", 1, MUTED)
    when 3
      step = 66
      block_h = (lines.length - 1) * step + 80
      start_y = 252 + (480 - 252 - block_h) / 2
      lines.each_with_index do |ln, i|
        draw_text(img, 90, start_y + i * step, ln, 2, WHITE)
      end
    else
      step = 60
      block_h = (lines.length - 1) * step + 80
      start_y = 246
      lines.each_with_index do |ln, i|
        draw_text(img, 90, start_y + i * step, ln, 2, WHITE)
      end
    end
    img.save(path)
  end
  def inside_rounded?(x, y, size, r)
    return true if (x >= r && x < size - r) || (y >= r && y < size - r)

    cx = x < r ? r : size - 1 - r
    cy = y < r ? r : size - 1 - r
    (x - cx)**2 + (y - cy)**2 <= r * r
  end

  def icon_canvas(size, rounded)
    img = ChunkyPNG::Image.new(size, size, ChunkyPNG::Color::TRANSPARENT)
    if rounded
      r = (size * 0.22).round
      size.times do |y|
        size.times do |x|
          img[x, y] = BG if inside_rounded?(x, y, size, r)
        end
      end
    else
      img = ChunkyPNG::Image.new(size, size, BG)
    end
    m = size * 0.74
    mark(img, (size - m) / 2.0, (size - m) / 2.0, m, WHITE)
    img
  end

  # Writes the full branded favicon set (PNGs + ICO) into dir, replacing the
  # theme defaults. Returns the list of file names written.
  def favicon_set(dir)
    require "fileutils"
    FileUtils.mkdir_p(dir)
    made = []
    { "favicon-16x16.png" => [16, true], "favicon-32x32.png" => [32, true], "favicon-96x96.png" => [96, true],
      "apple-touch-icon.png" => [180, false],
      "android-chrome-192x192.png" => [192, false],
      "android-chrome-512x512.png" => [512, false] }.each do |name, (size, rounded)|
      icon_canvas(size, rounded).save(File.join(dir, name))
      made << name
    end
    png16 = icon_canvas(16, true).to_blob
    png32 = icon_canvas(32, true).to_blob
    ico = [0, 1, 2].pack("v3")
    ico << [32, 32, 0, 0, 1, 32, png32.bytesize, 6 + 32].pack("CCCCvvVV")
    ico << [16, 16, 0, 0, 1, 32, png16.bytesize, 6 + 32 + png32.bytesize].pack("CCCCvvVV")
    ico << png32 << png16
    File.binwrite(File.join(dir, "favicon.ico"), ico)
    made << "favicon.ico"
    made
  end
end
