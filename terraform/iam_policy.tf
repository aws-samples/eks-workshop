data "aws_iam_policy_document" "codebuild" {
  statement {
    sid = "1"
    actions = [
         "s3:GetObjectVersionTagging",
         "s3:CreateBucket",
         "s3:ReplicateObject",
         "s3:GetObjectAcl",
         "s3:DeleteBucketWebsite",
         "s3:PutLifecycleConfiguration",
         "s3:GetObjectVersionAcl",
         "s3:PutObjectTagging",
         "s3:DeleteObject",
         "s3:GetIpConfiguration",
         "s3:DeleteObjectTagging",
         "s3:GetBucketWebsite",
         "s3:PutReplicationConfiguration",
         "s3:DeleteObjectVersionTagging",
         "s3:GetBucketNotification",
         "s3:PutBucketCORS",
         "s3:GetReplicationConfiguration",
         "s3:ListMultipartUploadParts",
         "s3:GetObject",
         "s3:PutBucketNotification",
         "s3:PutObject",
         "s3:PutBucketLogging",
         "s3:GetAnalyticsConfiguration",
         "s3:GetObjectVersionForReplication",
         "s3:GetLifecycleConfiguration",
         "s3:ListBucketByTags",
         "s3:GetBucketTagging",
         "s3:GetInventoryConfiguration",
         "s3:PutAccelerateConfiguration",
         "s3:DeleteObjectVersion",
         "s3:GetBucketLogging",
         "s3:ListBucketVersions",
         "s3:ReplicateTags",
         "s3:RestoreObject",
         "s3:GetAccelerateConfiguration",
         "s3:ListBucket",
         "s3:GetBucketPolicy",
         "s3:PutEncryptionConfiguration",
         "s3:GetEncryptionConfiguration",
         "s3:GetObjectVersionTorrent",
         "s3:AbortMultipartUpload",
         "s3:GetBucketRequestPayment",
         "s3:PutBucketTagging",
         "s3:GetObjectTagging",
         "s3:GetMetricsConfiguration",
         "s3:DeleteBucket",
         "s3:PutBucketVersioning",
         "s3:ListBucketMultipartUploads",
         "s3:PutMetricsConfiguration",
         "s3:PutObjectVersionTagging",
         "s3:GetBucketVersioning",
         "s3:GetBucketAcl",
         "s3:PutInventoryConfiguration",
         "s3:PutIpConfiguration",
         "s3:GetObjectTorrent",
         "s3:PutBucketRequestPayment",
         "s3:PutBucketWebsite",
         "s3:GetBucketCORS",
         "s3:GetBucketLocation",
         "s3:GetObjectVersion",
         "s3:ReplicateDelete"
    ]
    resources = [
      "${aws_s3_bucket.site_bucket.arn}",
      "${aws_s3_bucket.site_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation"
    ]
    resources = [
      "*"
    ]
  }

  # from https://docs.aws.amazon.com/codebuild/latest/userguide/setting-up.html#setting-up-service-role
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "acm:ListCertificates",
      "iam:ListServerCertificates",
      "waf:ListWebACLs",
      "waf:GetWebACL"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "${var.namespace}_codebuild"
  path   = "/"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}

resource "aws_iam_role_policy_attachment" "attach-codebuild-policy" {
    role       = "${module.iam_assume_role.this_iam_role_name}"
    policy_arn = "${aws_iam_policy.codebuild.arn}"
}
