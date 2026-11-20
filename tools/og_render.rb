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
    mark(img, 90, 165, 300, WHITE)
    draw_text(img, 424, 240, "loop and stack", 4, WHITE)
    draw_text(img, 428, 420, "all about the tools that power modern tech", 2, MUTED)
    img.save(path)
  end

  def post_card(path, title)
    img = base_canvas
    mark(img, 70, 55, 120, WHITE)
    draw_text(img, 196, 62, "loop and stack", 3, WHITE)
    lines = wrap(title, 31)
    if lines.length > 3
      lines = lines[0, 3]
      lines[2] = lines[2][0, 30].rstrip + "\u2026"
    end
    lines.each_with_index do |ln, i|
      draw_text(img, 90, 235 + i * 88, ln, 2, WHITE)
    end
    draw_text(img, 90, 545, "loopandstack.tech", 1, MUTED)
    img.save(path)
  end
end
