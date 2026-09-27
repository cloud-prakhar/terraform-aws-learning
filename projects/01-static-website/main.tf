# Architecture: visitors → CloudFront (HTTPS) → private S3 bucket.
# The bucket is NEVER public. CloudFront signs its requests to S3 with
# Origin Access Control (OAC), and the bucket policy only trusts this
# specific distribution.

locals {
  # File extension → Content-Type header, so browsers render files correctly.
  content_types = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    png  = "image/png"
    svg  = "image/svg+xml"
  }

  site_files = fileset("${path.module}/site", "**")
}

# ------------------------------ storage ------------------------------------

resource "aws_s3_bucket" "site" {
  #checkov:skip=CKV_AWS_21:Site content is deployed from Git, which is the version history.
  #checkov:skip=CKV2_AWS_61:Objects are managed by Terraform; nothing to expire.
  bucket_prefix = "${var.project_name}-"
  force_destroy = true # website content is re-uploaded from ./site
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# One aws_s3_object per file in ./site. etag = file hash, so editing a
# file makes Terraform upload the new version.
resource "aws_s3_object" "site" {
  for_each = local.site_files

  bucket       = aws_s3_bucket.site.id
  key          = each.value
  source       = "${path.module}/site/${each.value}"
  etag         = filemd5("${path.module}/site/${each.value}")
  content_type = lookup(local.content_types, reverse(split(".", each.value))[0], "application/octet-stream")
}

# ------------------------------ CDN ----------------------------------------

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.project_name}-oac"
  description                       = "Lets CloudFront read the private site bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# AWS managed cache policy "CachingOptimized", looked up by name
# instead of hard-coding its ID.
data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}

# AWS managed policy that adds HSTS, X-Content-Type-Options,
# X-Frame-Options and other security headers to every response.
data "aws_cloudfront_response_headers_policy" "security" {
  name = "Managed-SecurityHeadersPolicy"
}

# COST: CloudFront bills per request and per GB delivered. A personal
# test site produces very little traffic, but check current pricing.
resource "aws_cloudfront_distribution" "site" {
  #checkov:skip=CKV_AWS_174:The default *.cloudfront.net certificate does not allow choosing a minimum TLS version; a custom domain + ACM certificate would.
  enabled             = true
  comment             = "${var.project_name} static site"
  default_root_object = "index.html"
  price_class         = var.price_class
  is_ipv6_enabled     = true

  origin {
    origin_id                = "s3-site"
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id           = "s3-site"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.optimized.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.security.id
    compress                   = true
  }

  # With OAC, S3 returns 403 (not 404) for missing objects when the
  # caller may not list the bucket. Map it to our 404 page.
  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Uses the *.cloudfront.net certificate. A custom domain would need an
  # ACM certificate in us-east-1 and a Route 53 alias record.
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# Bucket policy: allow s3:GetObject ONLY for requests signed by the
# CloudFront service on behalf of THIS distribution.
data "aws_iam_policy_document" "site" {
  statement {
    sid       = "AllowCloudFrontRead"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.site.arn, "${aws_s3_bucket.site.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site.json

  depends_on = [aws_s3_bucket_public_access_block.site]
}
