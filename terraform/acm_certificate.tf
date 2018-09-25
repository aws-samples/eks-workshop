module "acm_request_certificate" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.1.3"
  domain_name                      = "${var.dnsdomain}"
  proces_domain_validation_options = "false" # if r53 domain is enabled, then process dns validation, otherwise don't
  ttl                              = "300"
}
