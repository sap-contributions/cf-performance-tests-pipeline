variable "parent_zone_id" {
  type = "string"
}

resource "aws_route53_record" "perf-test" {
  allow_overwrite = true
  name            = "${var.system_domain}"
  ttl             = 172800
  type            = "NS"
  zone_id         = "${var.parent_zone_id}"

  records = ["${aws_route53_zone.env_dns_zone.name_servers}"]
}