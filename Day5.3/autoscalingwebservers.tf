

# AWS, Launch Templates for Web Servers1 (Configuration Templates) for Main Site
resource "aws_launch_template" "Launch_Template_WebServers1" {
  name                                 = "Launch_Template_WebServers1"
  description                          = "WebServers1, Main Site"
  image_id                             = data.aws_ami.App_Ami.id
  instance_type                        = var.instance_type
  vpc_security_group_ids               = [aws_security_group.Web-Servers-SG.id]
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = var.key_name
  user_data                            = filebase64(var.user_data_webservers1)
  # user_data = filebase64("${var.user_data_webservers1}")
}

/*
data "template_file" "WebServers1_User_Data" {
  template = "${file("${var.user_data_webservers1}")}"
}
*/


# AWS, Launch Templates for Web Servers 2 (Configuration Templates) for Razor's Family Site
resource "aws_launch_template" "Launch_Template_WebServers2" {
  name                                 = "Launch_Template_WebServers2"
  description                          = "WebServers2, Razor's Family Site"
  image_id                             = data.aws_ami.App_Ami.id
  instance_type                        = var.instance_type
  vpc_security_group_ids               = [aws_security_group.Web-Servers-SG.id]
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = var.key_name
  user_data                            = filebase64(var.user_data_webservers2)
  # user_data = filebase64("${var.user_data_webservers2}")
}

/*
data "template_file" "WebServers2_User_Data" {
  template = "${file("${var.user_data_webservers2}")}"
}
*/


# AWS, Instance Target Group for Web Servers 1 for Main Site
/* ALB can't be used with Autoscaling Group without using Target Groups.
ELB can be used with Autoscaling without Target Group.
https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
https://www.terraform.io/docs/providers/aws/r/lb_cookie_stickiness_policy.html
*/
resource "aws_lb_target_group" "TargetGroup-WebServers1" {
  name                 = "TargetGroup-WebServers1"
  port                 = 80
  protocol             = "HTTP"
  slow_start           = 180
  deregistration_delay = 30
  # load_balancing_algorithm_type = "least_outstanding_requests" (You cannot enable both slow start and least outstanding requests algorithm on a target group)
  vpc_id = aws_vpc.VPC.id

  health_check {
    interval = 30
    # path                = "/var/www/html/index.html"
    path                = "/"
    port                = var.http_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }

  tags = {
    Allocation = "For Web Servers1"
    Relation   = "Web-Servers-ALB - Main Site"
  }
}

# AWS, Instance Target Group for Web Servers 2 for Razor's Family Site
resource "aws_lb_target_group" "TargetGroup-WebServers2" {
  name                 = "TargetGroup-WebServers2"
  port                 = 80
  protocol             = "HTTP"
  slow_start           = 180
  deregistration_delay = 30
  vpc_id               = aws_vpc.VPC.id

  health_check {
    interval = 30
    # path                = "/var/www/html/index.html"
    path                = "/"
    port                = var.http_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }

  tags = {
    Allocation = "For Web Servers 2"
    Relation   = "Razors-Family-Site"
  }
}

# AWS, Autoscaling Group for Web Servers (Groups) - Main Site
# https://www.terraform.io/docs/providers/aws/r/autoscaling_group.html
resource "aws_autoscaling_group" "ASG_WebServers1" {
  name                      = "ASG_WebServers1"
  max_size                  = 4
  min_size                  = length(var.aws_availability_zones)
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = length(var.aws_availability_zones)
  force_delete              = true
  vpc_zone_identifier       = ["${aws_subnet.PrivateSub-WebServers[0].id}", "${aws_subnet.PrivateSub-WebServers[1].id}"]

  launch_template {
    id      = aws_launch_template.Launch_Template_WebServers1.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebServers1"
    propagate_at_launch = true
  }
}

# AWS, Autoscaling Group for Web Servers 2 (Groups) - Razor's Family
resource "aws_autoscaling_group" "ASG_WebServers2" {
  name                      = "ASG_WebServers2"
  max_size                  = 4
  min_size                  = length(var.aws_availability_zones)
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = length(var.aws_availability_zones)
  force_delete              = true
  vpc_zone_identifier       = ["${aws_subnet.PrivateSub-WebServers[0].id}", "${aws_subnet.PrivateSub-WebServers[1].id}"]

  launch_template {
    id      = aws_launch_template.Launch_Template_WebServers2.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebServers2"
    propagate_at_launch = true
  }
}


# AWS, Target Group attachment with Autoscaling Group - Main Site
/*
https://www.terraform.io/docs/providers/aws/r/autoscaling_attachment.html
*/
resource "aws_autoscaling_attachment" "TargetGroup-WebServers1-To-ASG" {
  autoscaling_group_name = aws_autoscaling_group.ASG_WebServers1.id
  alb_target_group_arn   = aws_lb_target_group.TargetGroup-WebServers1.arn
}


# AWS, Target Group attachment with Autoscaling Group - Razor's Family Site
resource "aws_autoscaling_attachment" "TargetGroup-WebServers2-To-ASG" {
  autoscaling_group_name = aws_autoscaling_group.ASG_WebServers2.id
  alb_target_group_arn   = aws_lb_target_group.TargetGroup-WebServers2.arn
}


# AWS, Autoscaling Policy (Scaling Options), For Web Servers 1 - Main Site
/*
https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
*/
resource "aws_autoscaling_policy" "AutoScaling_Policy_WebServers1" {
  name        = "AutoScaling_Policy_WebServers1"
  policy_type = "TargetTrackingScaling"
  # cooldown    = 300 (Cooldown is only supported for policy type SimpleScaling)

  # estimated_instance_warmup = Health Check Grace Period
  /* A time period set for the auto scaling group to check whether the instance is already healthy or not.
*/
  estimated_instance_warmup = 200
  autoscaling_group_name    = aws_autoscaling_group.ASG_WebServers1.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "60.0"
  }
}


# AWS, Autoscaling Policy (Scaling Options), For Web Servers 2 - Razor's Family Site
resource "aws_autoscaling_policy" "AutoScaling_Policy_WebServers2" {
  name                      = "AutoScaling_Policy_WebServers2"
  policy_type               = "TargetTrackingScaling"
  estimated_instance_warmup = 200
  autoscaling_group_name    = aws_autoscaling_group.ASG_WebServers1.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "60.0"
  }
}