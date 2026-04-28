variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block da VPC"
  type        = string
}

variable "availability_zones" {
  description = "Lista de AZs"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDRs das subnets públicas"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDRs das subnets privadas"
  type        = list(string)
}

variable "database_subnets" {
  description = "CIDRs das subnets de banco de dados"
  type        = list(string)
}