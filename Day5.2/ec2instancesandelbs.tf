

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
  iam_instance_profile        = aws_iam_instance_profile.EC2_To_S3_Profile.name
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


/*
# AWS, Web Servers, Accross AZs
resource "aws_instance" "WebServers" {
  count                  = length(var.aws_availability_zones)
  ami                    = data.aws_ami.App_Ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.Web-Servers-SG.id]
  subnet_id              = aws_subnet.PrivateSub-WebServers[count.index].id
  iam_instance_profile   = aws_iam_instance_profile.EC2_To_S3_Profile.name
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
  instance_ip=`curl "http://169.254.169.254/latest/meta-data/local-ipv4"`
  /bin/echo $instance_ip >> /var/www/html/index.html
EOF
}
*/


# AWS, App Servers, Accross AZs
resource "aws_instance" "AppServers" {
  count                  = length(var.aws_availability_zones)
  ami                    = data.aws_ami.App_Ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.App-Servers-SG.id]
  subnet_id              = aws_subnet.PrivateSub-AppServers[count.index].id
  iam_instance_profile   = aws_iam_instance_profile.EC2_To_S3_Profile.name
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
  instance_ip=`curl "http://169.254.169.254/latest/meta-data/local-ipv4"`
  /bin/echo $instance_ip >> /var/www/html/index.html
EOF
}


/*
# AWS, DB Servers, Accross AZs
resource "aws_instance" "DBServers" {
  count                  = length(var.aws_availability_zones)
  ami                    = data.aws_ami.App_Ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.DB-Servers-SG.id]
  subnet_id              = aws_subnet.PrivateSub-DBServers[count.index].id
  iam_instance_profile   = aws_iam_instance_profile.EC2_To_S3_Profile.name
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
*/


# AWS, Application Load Balancer for Web Servers
# Use Data Sources to get Load Balancer ARN to be used in LB Listner.
/*
  data "aws_lb" "web_servers_lb_data" {
  arn  = "var.webservers_alb_arn"
  name = "var.webservers_alb_name"
}
*/


resource "aws_lb" "Web-Servers-ALB" {
  name                       = "Web-Servers-ALB"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.Web-Servers-SG.id]
  subnets                    = ["${aws_subnet.PublicSub-BastionHosts[0].id}", "${aws_subnet.PublicSub-BastionHosts[1].id}"]
  enable_deletion_protection = false
  idle_timeout               = 60
  ip_address_type            = "ipv4"
  #  subnet                    = ["${aws_subnet.PublicSub-BastionHosts[0].id}", "${aws_subnet.PublicSub-BastionHosts[1].id}"]
  #  cross_zone_load_balancing = true
  #  instances                 = ["${aws_instance.WebServers[0].id}", "${aws_instance.WebServers[1].id}"]
  depends_on = [
    aws_s3_bucket.App-S3-All,
    aws_s3_bucket_object.Web-Servers-ALB-Logs
  ]

  # https://thepracticalsysadmin.com/configure-s3-to-store-load-balancer-logs-using-terraform/
  access_logs {
    bucket  = "cloudgurus-s3-applications-all"
    prefix  = "Web-Servers-ALB-Logs"
    enabled = true
  }

  tags = {
    Environment = "Web-Servers-ALB"
    Location    = "Public"
  }
}


# AWS, Application Load Balancer Listener and Listener Rule
/*
https://www.terraform.io/docs/providers/aws/r/lb_listener.html
https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
*/

resource "aws_lb_listener" "Listener-ALB-WebServers" {
  load_balancer_arn = aws_lb.Web-Servers-ALB.arn
  # load_balancer_arn = "arn:aws:elasticloadbalancing:us-east-1:628584336379:loadbalancer/app/Web-Servers-ALB/2e71f6cf23e812bf"
  port     = "80"
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TargetGroup-WebServers.arn
    #   target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:628584336379:targetgroup/TargetGroup-WebServers/abb93b0870b2a188"
  }
}


/*
resource "aws_lb_listener_rule" "Listener_Rule_ALB_WebServers" {
  listener_arn = "aws_lb_listener.Listener-ALB-WebServers.arn"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "aws_lb_target_group.TargetGroup-WebServers.arn"
  }

  condition {}
}
*/


# AWS, Load Balancer for App Servers
resource "aws_elb" "App-Servers-ELB" {
  name                      = "App-Servers-ELB"
  internal                  = true
  security_groups           = [aws_security_group.App-Servers-SG.id]
  subnets                   = ["${aws_subnet.PrivateSub-AppServers[0].id}", "${aws_subnet.PrivateSub-AppServers[1].id}"]
  cross_zone_load_balancing = true
  instances                 = ["${aws_instance.AppServers[0].id}", "${aws_instance.AppServers[1].id}"]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = var.http_port
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.http_port}/"
  }
}