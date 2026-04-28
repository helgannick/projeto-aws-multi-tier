output "vpc_id" {
  description = "ID da VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR da VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "IDs das subnets de banco de dados"
  value       = module.vpc.database_subnet_ids
}

output "nat_gateway_ip" {
  description = "IP público do NAT Gateway"
  value       = module.vpc.nat_gateway_ip
}

output "alb_dns_name" {
  description = "URL pública do Load Balancer — acesse no navegador!"
  value       = module.alb.alb_dns_name
}

output "asg_name" {
  description = "Nome do Auto Scaling Group"
  value       = module.ec2_asg.asg_name
}

output "rds_endpoint" {
  description = "Endpoint do RDS PostgreSQL"
  value       = module.rds.rds_endpoint
  sensitive   = true
}