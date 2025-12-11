data "aws_route53_zone" "host_zone" {
    name = var.host_zone_name
    private_zone = false
}

resource "aws_route53_record" "alb_alias" {
    zone_id = data.aws_route53_zone.host_zone.zone_id
    name = "wordpress.${var.host_zone_name}"
    type = "A"

    alias {
        name = var.alb_dns_name
        zone_id = var.alb_zone_id
        evaluate_target_health = true
    }
}