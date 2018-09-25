data "aws_iam_policy_document" "site_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.github_owner}-${var.dnsdomain}/*"]
    # resources = ["${aws_s3_bucket.site_bucket.bucket}/*"] # The policy needs
    # to exist before the bucket, so we can't point the resource at the resource name
    # of the TF resource below.

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket" "site_bucket" {
  bucket        = "${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-${var.github_owner}-${var.dnsdomain}"
  acl           = "private"
  force_destroy = false

  website {
    index_document = "index.html"
  }

  policy = "${data.aws_iam_policy_document.site_policy.json}"
}
