resource "aws_route53_zone" "primary" {
  count = "${var.route53_enabled}"
  name = "${var.dnsdomain}"
}

resource "aws_route53_record" "www" {
  count = "${var.route53_enabled}"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "www.${var.dnsdomain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${var.dnsdomain}"]
}

resource "aws_route53_record" "apex" {
  count = "${var.route53_enabled}"
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name    = "${var.dnsdomain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.distribution.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

output "nameservers to use at your DNS registrar" {
  value = "${aws_route53_zone.primary.*.name_servers}"
}
