

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
http_port        = 80
ssh_port         = 22
webservers2_port = 900
withinvpc_all    = ["192.168.0.0/16"]
external_all     = ["0.0.0.0/0"]

# AWS, Machine Images and Instance Types
instance_type = "t2.micro"
# ami           = "ami-0a887e401f7654935"

# Bastion Host Names
bastionhost_names = ["BastionHost-Dev-Primary", "BastionHost-Pro-Primary"]

/*
# Web Servers' Apllication Load Balancer Name and ARN
webservers_alb_name = "Web-Servers-ALB"
webservers_alb_arn  = "Web-Servers-ALB-ARN"
*/

# AWS, Key Pair for N.Virginia
key_name = "virginia_keypair"

# AWS, User datas for Web Servers for Luanch Template
user_data_webservers1 = "/user_data_webservers1.sh"

# AWS, User datas for Web Servers for Luanch Template for Razor's Family
user_data_webservers2 = "/user_data_webservers2.sh"

# AWS, S3 Bucket Name and Object Names
s3_bucket_name     = "cloud-gurus-s3-applications-all"
s3_object_alb_logs = "Web-Servers-ALB-Logs"