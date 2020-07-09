

# AWS, AMI Images, "Using Data Sources"
# Amazon AMI, depends upon the AWS Region
/*
Amazon Linux 2 AMI IDs
https://aws.amazon.com/amazon-linux-2/release-notes/
*/
data "aws_ami" "App_Ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# AWS, Basion Hosts, Accross AZs
resource "aws_instance" "Bastion-Hosts" {
  count                       = length(var.aws_availability_zones)
  ami                         = data.aws_ami.App_Ami.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.Bastion-Hosts-SG.id]
  subnet_id                   = aws_subnet.PublicSub-BastionHosts[count.index].id
  associate_public_ip_address = "true"
  key_name                    = var.key_name
  tags = {
    Name = element(var.bastionhost_names, count.index)
  }
  user_data = <<EOF
#! /bin/bash
yum update -y
yum install firewalld -y
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --reload
EOF
}

# AWS, Web Servers, Accross AZs
resource "aws_instance" "WebServers" {
  count                  = length(var.aws_availability_zones)
  ami                    = data.aws_ami.App_Ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Web-Servers-SG.id]
  subnet_id              = aws_subnet.PrivateSub-WebServers[count.index].id
  key_name               = var.key_name
  tags = {
    Name = "WebServers${count.index + 1}"
  }
  user_data = <<EOF
  #! /bin/bash
  yum update -y
  yum install httpd -y
  chmod -R 777 /var/www
  /bin/echo "Nuwan's Tech Talk.!" > /var/www/html/index.html
  /bin/echo " / www.nuwan.vip / " >> /var/www/html/index.html
  systemctl start httpd
  systemctl enable httpd
  yum install firewalld -y
  systemctl start firewalld
  systemctl enable firewalld
  firewall-cmd --zone=public --add-port=80/tcp --permanent
  firewall-cmd --zone=public --add-port=22/tcp --permanent
  firewall-cmd --reload
  instance_ip=`curl "http://169.254.169.254/latest/meta-data/public-ipv4"`
  /bin/echo $instance_ip >> /var/www/html/index.html
EOF
}

# AWS, App Servers, Accross AZs
resource "aws_instance" "AppServers" {
  count                  = length(var.aws_availability_zones)
  ami                    = data.aws_ami.App_Ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.App-Servers-SG.id]
  subnet_id              = aws_subnet.PrivateSub-AppServers[count.index].id
  key_name               = var.key_name
  tags = {
    Name = "AppServers${count.index + 1}"
  }
  user_data = <<EOF
  #! /bin/bash
  yum update -y
  yum install httpd -y
  chmod -R 777 /var/www
  /bin/echo "Nuwan's Tech Talk.!" > /var/www/html/index.html
  /bin/echo " / www.nuwan.vip / " >> /var/www/html/index.html
  systemctl start httpd
  systemctl enable httpd
  yum install firewalld -y
  systemctl start firewalld
  systemctl enable firewalld
  firewall-cmd --zone=public --add-port=80/tcp --permanent
  firewall-cmd --zone=public --add-port=22/tcp --permanent
  firewall-cmd --reload
  instance_ip=`curl "http://169.254.169.254/latest/meta-data/public-ipv4"`
  /bin/echo $instance_ip >> /var/www/html/index.html
EOF
}

# AWS, DB Servers, Accross AZs
resource "aws_instance" "DBServers" {
  count                  = length(var.aws_availability_zones)
  ami                    = data.aws_ami.App_Ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.DB-Servers-SG.id]
  subnet_id              = aws_subnet.PrivateSub-DBServers[count.index].id
  key_name               = var.key_name
  tags = {
    Name = "DBServers${count.index + 1}"
  }
  user_data = <<EOF
  #! /bin/bash
  yum update -y
  yum install firewalld -y
  systemctl start firewalld
  systemctl enable firewalld
  firewall-cmd --zone=public --add-port=22/tcp --permanent
  firewall-cmd --reload
EOF
}