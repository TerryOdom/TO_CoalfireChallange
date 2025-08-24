# ------------------------------------------------------------------
# FILE: modules/security/outputs.tf
# ------------------------------------------------------------------

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "mgmt_sg_id" {
  value = aws_security_group.mgmt.id
}

output "app_sg_id" {
  value = aws_security_group.app.id
}

