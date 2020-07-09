

# AWS, VPC
resource "aws_vpc" "VPC" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = var.aws_vpc_tenancy
  tags = {
    Name     = "VPC"
    Location = "N.Virginia"
  }
}

# AWS, Internet Gateay
resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "IGW"
  }
}


# AWS, Subnets
# Public Subnets for Bastion Hosts and NAT Gateway
resource "aws_subnet" "PublicSub-BastionHosts" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = element(var.aws_public_subnets_cidr_bastionhosts, count.index)
  availability_zone = element(var.aws_availability_zones, count.index)

  tags = {
    Name = "PublicSub-BastionHosts${count.index + 1}"
  }
}

# Private Subnets for Web Servers
resource "aws_subnet" "PrivateSub-WebServers" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = element(var.aws_private_subnets_cidr_webservers, count.index)
  availability_zone = element(var.aws_availability_zones, count.index)

  tags = {
    Name = "PrivateSub-WebServers${count.index + 1}"
  }
}

# Private Subnets for App Servers
resource "aws_subnet" "PrivateSub-AppServers" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = element(var.aws_private_subnets_cidr_appservers, count.index)
  availability_zone = element(var.aws_availability_zones, count.index)

  tags = {
    Name = "PrivateSub-AppServers${count.index + 1}"
  }
}

# Private Subnets for DB Servers
resource "aws_subnet" "PrivateSub-DBServers" {
  count             = length(var.aws_availability_zones)
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = element(var.aws_private_subnets_cidr_dbservers, count.index)
  availability_zone = element(var.aws_availability_zones, count.index)

  tags = {
    Name = "PrivateSub-DBServers${count.index + 1}"
  }
}
