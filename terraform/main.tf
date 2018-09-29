output "cloudfront URL" {
  value = "${aws_cloudfront_distribution.distribution.domain_name}"
}
output "Build Badge URL" {
  value = "${aws_codebuild_project.codebuild.badge_url}"
}
