variable "project_name"          { type = string }
variable "environment"           { type = string }
variable "asg_name"              { type = string }
variable "alb_arn_suffix"        { type = string }
variable "rds_identifier"        { type = string }
variable "scale_out_policy_arn"  { type = string }
variable "scale_in_policy_arn"   { type = string }

variable "alert_email" {
  description = "Email para receber alertas do CloudWatch"
  type        = string
}