resource "aws_codebuild_project" "codebuild" {
  name         = "${var.namespace}-build"
  build_timeout      = "5"
  service_role = "${module.iam_assume_role.this_iam_role_arn}"
  badge_enabled = "true"

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image        = "aws/codebuild/nodejs:10.1.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = "true"

  environment_variable {
  "name"  = "CLOUDFRONT"
  "value" = "${aws_cloudfront_distribution.distribution.id}"
  }

  environment_variable {
  "name"  = "PRIMARY_BUCKET"
  "value" = "${aws_s3_bucket.site_bucket.website_endpoint}"
  }

  }
  source {
    type            = "GITHUB"
    location        = "${var.github_url}"
    git_clone_depth = 0
    report_build_status = true
    auth = {
      type = "OAUTH"
      resource = "${var.GITHUB_TOKEN}"
    }
  }

  }

resource "aws_codebuild_webhook" "codebuild" {
  project_name = "${aws_codebuild_project.codebuild.name}"
}
