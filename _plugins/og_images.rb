# frozen_string_literal: true

require "json"
require "open3"

# Generates branded OG share-card PNGs into the built site at /assets/og/
# by running tools/og_render.py after the site is written. Fails soft so a
# renderer problem can never break the deploy.
Jekyll::Hooks.register :site, :post_write do |site|
  begin
    posts = site.posts.docs.map do |doc|
      { "slug" => doc.data["slug"].to_s, "title" => doc.data["title"].to_s }
    end
    payload = { "posts" => posts, "out" => File.join(site.dest, "assets", "og") }
    tmp = File.join(site.source, "tools", ".og_payload.json")
    File.write(tmp, JSON.generate(payload))
    script = File.join(site.source, "tools", "og_render.py")
    out, status = Open3.capture2e("python3", script, tmp)
    if status.success?
      Jekyll.logger.info "OG images:", out.strip
    else
      Jekyll.logger.warn "OG images:", "renderer failed: #{out.strip[0, 400]}"
    end
  rescue StandardError => e
    Jekyll.logger.warn "OG images:", e.message
  end
end
