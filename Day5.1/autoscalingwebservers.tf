

# AWS, Launch Configuration for Web Servers (Configuration Templates)
resource "aws_launch_configuration" "Launch_Config_WebServers" {
  name                        = "Launch_Config_WebServers"
  image_id                    = data.aws_ami.App_Ami.id
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.Web-Servers-SG.id]
  associate_public_ip_address = "false"
  key_name                    = var.key_name
  user_data                   = <<EOF
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

# AWS, Autoscaling Group for Web Servers (Groups)
# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "ASG_WebServers" {
  name                      = "ASG_WebServers"
  max_size                  = 4
  min_size                  = length(var.aws_availability_zones)
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = length(var.aws_availability_zones)
  force_delete              = true
  launch_configuration      = aws_launch_configuration.Launch_Config_WebServers.id
  vpc_zone_identifier       = ["${aws_subnet.PrivateSub-WebServers[0].id}", "${aws_subnet.PrivateSub-WebServers[1].id}"]

  tag {
    key                 = "Name"
    value               = "WebServers"
    propagate_at_launch = true
  }
}

# AWS, Autoscaling Policy (Scaling Options)
/*
https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
*/
resource "aws_autoscaling_policy" "AutoScaling_Policy_WebServers" {
  name        = "AutoScaling_Policy_WebServers"
  policy_type = "TargetTrackingScaling"
  cooldown    = 300

  # estimated_instance_warmup = Health Check Grace Period
  /* A time period set for the auto scaling group to check whether the instance is already healthy or not.
*/
  estimated_instance_warmup = 200
  autoscaling_group_name    = aws_autoscaling_group.ASG_WebServers.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "60.0"
  }
}