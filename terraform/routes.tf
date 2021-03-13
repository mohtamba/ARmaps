resource "aws_route53_record" "dns" {
  zone_id = "Z10101041940SBIR0QOOZ"
  name    = "api.armaps.net"
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = aws_lb.loadbalancer.dns_name
    zone_id                = aws_lb.loadbalancer.zone_id
  }
}