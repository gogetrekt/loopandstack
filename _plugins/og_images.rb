# frozen_string_literal: true

require "fileutils"

# Generates branded OG share-card PNGs into the built site at /assets/og/
# using the pure-Ruby renderer in tools/og_render.rb (chunky_png + embedded
# VT323 glyphs). Fails soft so a renderer problem can never break the deploy,
# and leaves a status.txt diagnostic next to the images.
Jekyll::Hooks.register :site, :post_write do |site|
  out_dir = File.join(site.dest, "assets", "og")
  begin
    FileUtils.mkdir_p(out_dir)
    require File.join(site.source, "tools", "og_render.rb")
    LasOg.default_card(File.join(out_dir, "og-default.png"))
    made = ["og-default.png"]
    site.posts.docs.each do |doc|
      slug = doc.data["slug"].to_s
      title = doc.data["title"].to_s
      next if slug.empty? || title.empty?

      LasOg.post_card(File.join(out_dir, "#{slug}.png"), title)
      made << "#{slug}.png"
    end
    fav_dir = File.join(site.dest, "assets", "img", "favicons")
    favs = LasOg.favicon_set(fav_dir)
    require "fileutils"
    FileUtils.cp(File.join(fav_dir, "favicon.ico"), File.join(site.dest, "favicon.ico"))
    File.write(File.join(out_dir, "status.txt"), "ok #{Time.now.utc}\nfiles: #{made.sort.join(', ')}\nfavicons: #{favs.sort.join(', ')}\n")
  rescue StandardError => e
    begin
      FileUtils.mkdir_p(out_dir)
      File.write(File.join(out_dir, "status.txt"), "error #{e.class}: #{e.message}\n")
    rescue StandardError
      nil
    end
    Jekyll.logger.warn "OG images:", e.message
  end
end
