data "cloudflare_zone" "domain" {
    name = var.site_domain
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zone.domain.id
  name    = var.api_name
  value   = aws_s3_bucket.site.website_endpoint
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

# Add a page rule to force https
resource "cloudflare_page_rule" "https" {
  zone_id = data.cloudflare_zone.domain.id
  target  = "*.${var.site_domain}/*"
  actions {
    always_use_https = true
  }
}
