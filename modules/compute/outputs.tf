# ------------------------------------------------------------------
# FILE: modules/compute/outputs.tf
# ------------------------------------------------------------------

output "asg_name" {
  value = aws_autoscaling_group.app.name
}