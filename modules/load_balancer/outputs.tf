# ------------------------------------------------------------------
# FILE: modules/load_balancer/outputs.tf
# ------------------------------------------------------------------

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}
