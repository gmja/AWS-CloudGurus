

# AWS, Security Groups, Bastion Hosts, Public Access
resource "aws_security_group" "Bastion-Hosts-SG" {
  name        = "Bastion-Hosts-SG"
  description = "Public Access, SSH"
  vpc_id      = aws_vpc.VPC.id
  ingress {
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.external_all
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.external_all
  }
  tags = {
    Location = "N.Virginia"
  }
}

# AWS, Security Groups, Web Servers, Public Access and Bastion Hosts Access
resource "aws_security_group" "Web-Servers-SG" {
  name        = "Web-Servers-SG"
  description = "Public Access and Bastion Hosts Access, HTTP, SSH"
  vpc_id      = aws_vpc.VPC.id
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.external_all
  }
  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.Bastion-Hosts-SG.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.external_all
  }
  tags = {
    Location = "N.Virginia"
  }
}

# AWS, Security Groups, App Servers, Web Servers Access and Bastion Hosts Access
resource "aws_security_group" "App-Servers-SG" {
  name        = "App-Servers-SG"
  description = "Private Access and Bastion Hosts Access, HTTP, SSH"
  vpc_id      = aws_vpc.VPC.id
  ingress {
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.withinvpc_all
    #   security_groups = [aws_security_group.Web-Servers-SG.id]
  }
  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.Bastion-Hosts-SG.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.external_all
  }
  tags = {
    Location = "N.Virginia"
  }
}

# AWS, Security Groups, DB Servers, Access and Bastion Hosts Access
resource "aws_security_group" "DB-Servers-SG" {
  name        = "DB-Servers-SG"
  description = "Private Access and Bastion Hosts Access, SSH"
  vpc_id      = aws_vpc.VPC.id
  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.Bastion-Hosts-SG.id]
  }
  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.App-Servers-SG.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.external_all
  }
  tags = {
    Location = "N.Virginia"
  }
}