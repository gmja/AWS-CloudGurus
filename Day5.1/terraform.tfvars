

# AWS, Region
aws_region = "us-east-1"

# AWS, VPC, IPv4 CIDR Block
aws_vpc_cidr    = "192.168.0.0/16"
aws_vpc_tenancy = "default"

# AWS, Availability Zones [Using input variable type list(string)]
aws_availability_zones = ["us-east-1a", "us-east-1b"]

# AWS, Public and Private Subnets [Using input variable type list(string)]
aws_public_subnets_cidr_bastionhosts = ["192.168.1.0/24", "192.168.2.0/24"]
aws_private_subnets_cidr_webservers  = ["192.168.6.0/24", "192.168.7.0/24"]
aws_private_subnets_cidr_appservers  = ["192.168.11.0/24", "192.168.12.0/24"]
aws_private_subnets_cidr_dbservers   = ["192.168.16.0/24", "192.168.17.0/24"]

# Security Groups, For Web servers, Public Facing
http_port     = 80
ssh_port      = 22
withinvpc_all = ["192.168.0.0/16"]
external_all  = ["0.0.0.0/0"]

# AWS, Machine Images and Instance Types
instance_type = "t2.micro"
# ami           = "ami-0a887e401f7654935"

# Bastion Host Names
bastionhost_names = ["BastionHost-Dev-Primary", "BastionHost-Pro-Primary"]

# WebServers Names
webservers_names = ["WebServers1", "WebServers2", "WebServers3", "WebServers4", "WebServers5", "WebServers6"]

# AWS, Key Pair for N.Virginia
key_name = "virginia_keypair"
