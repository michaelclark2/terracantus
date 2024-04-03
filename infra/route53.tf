resource "aws_acm_certificate" "webapp-ssl-cert" {
  domain_name               = "terracantus.com"
  subject_alternative_names = ["*.terracantus.com"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn         = aws_acm_certificate.webapp-ssl-cert.arn
  validation_record_fqdns = [aws_route53_record.validation.fqdn]
}

resource "aws_route53_zone" "primary" {
  name = "terracantus.com"
}

resource "aws_route53_record" "validation" {
  zone_id = aws_route53_zone.primary.id
  name    = tolist(aws_acm_certificate.webapp-ssl-cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.webapp-ssl-cert.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.webapp-ssl-cert.domain_validation_options)[0].resource_record_value]
  ttl     = "300"
}

resource "aws_route53_record" "lb" {
  zone_id = aws_route53_zone.primary.id
  name    = "terracantus.com"
  type    = "A"
  alias {
    name                   = aws_lb.production.dns_name
    zone_id                = aws_lb.production.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "lb_cname" {
  zone_id = aws_route53_zone.primary.id
  name    = "www.terracantus.com"
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.production.dns_name]
}

output "nameserver-list" {
  value = aws_route53_zone.primary.name_servers
}
