

# AWS, Region
variable "aws_region" {}

# AWS, VPC, IPv4 CIDR Block
variable "aws_vpc_cidr" {}
variable "aws_vpc_tenancy" {}

# AWS, Availability Zones
variable "aws_availability_zones" {
  type = list(string)
}

# AWS, Public and Private Subnets
variable "aws_public_subnets_cidr_bastionhosts" {
  type = list(string)
}

variable "aws_private_subnets_cidr_webservers" {
  type = list(string)
}

variable "aws_private_subnets_cidr_appservers" {
  type = list(string)
}

variable "aws_private_subnets_cidr_dbservers" {
  type = list(string)
}