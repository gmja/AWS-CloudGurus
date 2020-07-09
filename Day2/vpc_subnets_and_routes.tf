

# AWS, VPC
resource "aws_vpc" "VPC" {
  cidr_block       = var.aws_vpc_cidr
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
    Name = "PrivateSub-DBbServers${count.index + 1}"
  }
}


## AWS, Route Table, Public Subnets
resource "aws_route_table" "PublicRT" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "PublicRT"
  }
}

## AWS, Route Table, Private Subnets
resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "PrivateRT"
  }
}

# BastionHosts' Subnets association with Route Table, Public for BastionHosts
resource "aws_route_table_association" "PublicRT-Association-BastionHosts" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.PublicSub-BastionHosts[count.index].id
  route_table_id = aws_route_table.PublicRT.id
  depends_on     = [aws_internet_gateway.IGW]
}

# WebServers' Subnets association with Route Table, Private for WebServers
resource "aws_route_table_association" "PrivateRT-Association-WebServers" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.PrivateSub-WebServers[count.index].id
  route_table_id = aws_route_table.PrivateRT.id
  depends_on     = [aws_internet_gateway.IGW]
}

# WebServers' Subnets association with Route Table, Private for AppServers
resource "aws_route_table_association" "PrivateRT-Association-AppServers" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.PrivateSub-AppServers[count.index].id
  route_table_id = aws_route_table.PrivateRT.id
  depends_on     = [aws_internet_gateway.IGW]
}

# WebServers' Subnets association with Route Table, Private for AppServers
resource "aws_route_table_association" "PrivateRT-Association-DBServers" {
  count          = length(var.aws_availability_zones)
  subnet_id      = aws_subnet.PrivateSub-DBServers[count.index].id
  route_table_id = aws_route_table.PrivateRT.id
  depends_on     = [aws_internet_gateway.IGW]
}
