# frozen_string_literal: true

require "json"
require "open3"
require "fileutils"

# Generates branded OG share-card PNGs into the built site at /assets/og/
# by running tools/og_render.py after the site is written. Fails soft so a
# renderer problem can never break the deploy. Also writes a status.txt
# diagnostic file next to the images.
Jekyll::Hooks.register :site, :post_write do |site|
  out_dir = File.join(site.dest, "assets", "og")
  begin
    FileUtils.mkdir_p(out_dir)
    posts = site.posts.docs.map do |doc|
      { "slug" => doc.data["slug"].to_s, "title" => doc.data["title"].to_s }
    end
    payload = { "posts" => posts, "out" => out_dir }
    tmp = File.join(site.source, "tools", ".og_payload.json")
    File.write(tmp, JSON.generate(payload))
    script = File.join(site.source, "tools", "og_render.py")
    pyver, = Open3.capture2e("python3", "--version")
    pil, pil_status = Open3.capture2e("python3", "-c", "import PIL; print(PIL.__version__)")
    out, status = Open3.capture2e("python3", script, tmp)
    magick, = Open3.capture2e("bash", "-c", "which magick convert rsvg-convert inkscape 2>/dev/null; magick --version 2>/dev/null | head -1; convert --version 2>/dev/null | head -1; rsvg-convert --version 2>/dev/null; fc-list 2>/dev/null | grep -ci dejavu; ls /usr/share/fonts/truetype/dejavu/ 2>/dev/null | head -4")
    lines = [
      "time: #{Time.now.utc}",
      "ruby: #{RUBY_VERSION}",
      "gfx tools: #{magick.strip[0, 500]}",
      "python: #{pyver.strip}",
      "pil preinstalled: #{pil_status.success?} #{pil.strip}",
      "renderer success: #{status.success?}",
      "renderer output: #{out.strip[0, 800]}",
      "files: #{Dir.exist?(out_dir) ? Dir.children(out_dir).sort.join(', ') : 'out dir missing'}"
    ]
    File.write(File.join(out_dir, "status.txt"), lines.join("\n") + "\n")
    Jekyll.logger.info "OG images:", out.strip
  rescue StandardError => e
    begin
      FileUtils.mkdir_p(out_dir)
      File.write(File.join(out_dir, "status.txt"), "hook error: #{e.class}: #{e.message}\n")
    rescue StandardError
      nil
    end
    Jekyll.logger.warn "OG images:", e.message
  end
end
