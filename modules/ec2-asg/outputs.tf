output "asg_name" {
  value = aws_autoscaling_group.main.name
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2.id
}

output "scale_out_policy_arn" {
  value = aws_autoscaling_policy.scale_out.arn
}

output "scale_in_policy_arn" {
  value = aws_autoscaling_policy.scale_in.arn
}