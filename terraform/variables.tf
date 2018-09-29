provider "aws" {
  region     = "us-east-1" # strongly recommended to use us-east-1 for ACM global certificate usage
}

variable "route53_enabled" {
  default = 1 # start with route53 disabled while in dev mode...
              # to "go live, for production", enable this, and run "terraform apply" again.
              # once that succeeds, modify cloudfront.tf:"viewer_certificate", uncommenting
              # acm_certificate_arn, and commenting out cloudfront_default_certificate.
              # Log in to ACM at: https://console.aws.amazon.com/acm/home?region=us-east-1#/ and
              # manually submit the route53 cname records for certificate validation.
              # Validation can take ~30 minutes. :(
              # Once validated, run "terraform apply" again to reconfigure the
              # cloudfront distro to use your ACM certificate.

              # P.S. this is janky because of ACM's manual validation jank. :(
}

variable "dnsdomain" {    # apex dns domain
  default = "eksworkshop.com"
}

variable "namespace" {    # Used in some naming. I use the domain name minus TLD.
  default = "eksworkshop"
}

variable "github_url" {   # Github URL (tested with https, not git://)
  default = "https://github.com/aws-samples/eks-workshop.git"
}

variable "github_owner" {
  default = "brentley"
}

variable "GITHUB_TOKEN" {} # this should be set in your environment as "TF_VAR_GITHUB_TOKEN"... so > export TF_GITHUB_TOKEN=xxxxxxx
