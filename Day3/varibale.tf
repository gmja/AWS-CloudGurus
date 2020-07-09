

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

# AWS, Security Groups
# Security Groups, For Web servers, Public Facing
variable "http_port" {}
variable "external_all" {}
variable "ssh_port" {}
variable "withinvpc_all" {}

# AWS, Machine Images and Instance Types
variable "ami" {}
variable "instance_type" {}

# AWS, Key Pair for N.Virginia
variable "key_name" {}
