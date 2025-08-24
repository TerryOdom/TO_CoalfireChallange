# ------------------------------------------------------------------
# FILE: modules/networking/outputs.tf
# ------------------------------------------------------------------

output "vpc_id" {
  value = aws_vpc.main.id
}

output "mgmt_subnet_id" {
  value = aws_subnet.mgmt.id
}

output "app_subnet_ids" {
  value = aws_subnet.app[*].id
}

