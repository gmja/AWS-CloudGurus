

# AWS, Launch Templates for Web Servers (Configuration Templates)
resource "aws_launch_template" "Launch_Template_WebServers" {
  name                                 = "Launch_Template_WebServers"
  description                          = "WebServers, Company Main Site"
  image_id                             = data.aws_ami.App_Ami.id
  instance_type                        = var.instance_type
  vpc_security_group_ids               = [aws_security_group.Web-Servers-SG.id]
  instance_initiated_shutdown_behavior = "terminate"
  key_name                             = var.key_name
  user_data                            = filebase64(var.user_data_webservers)
  # user_data = filebase64("${var.user_data_webservers}")
}

/* data "template_file" "WebServers_User_Data" {
  template = "${file("${var.user_data_webservers}")}"
}
*/


# AWS, Instance Target Group
/* ALB can't be used with Autoscaling Group without using Target Groups.
ELB can be used with Autoscaling without Target Group.
https://www.terraform.io/docs/providers/aws/r/lb_target_group.html
https://www.terraform.io/docs/providers/aws/r/lb_cookie_stickiness_policy.html
*/
resource "aws_lb_target_group" "TargetGroup-WebServers" {
  name                 = "TargetGroup-WebServers"
  port                 = 80
  protocol             = "HTTP"
  slow_start           = 180
  deregistration_delay = 30
  # load_balancing_algorithm_type = "least_outstanding_requests" (You cannot enable both slow start and least outstanding requests algorithm on a target group)
  vpc_id = aws_vpc.VPC.id

  health_check {
    interval = 30
    path     = "/"
    # path                = "/var/www/html/index.html"
    port                = var.http_port
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200,202"
  }

  tags = {
    Allocation = "For Web Servers"
    Relation   = "Web-Servers-ALB"
  }
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
  # launch_configuration      = aws_launch_configuration.Launch_Config_WebServers.id
  vpc_zone_identifier = ["${aws_subnet.PrivateSub-WebServers[0].id}", "${aws_subnet.PrivateSub-WebServers[1].id}"]

  launch_template {
    id      = aws_launch_template.Launch_Template_WebServers.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebServers"
    propagate_at_launch = true
  }
}


# AWS, Target Group attachment with Autoscaling Group
/*
https://www.terraform.io/docs/providers/aws/r/autoscaling_attachment.html
*/
resource "aws_autoscaling_attachment" "TargetGroup-WebServers-To-ASG" {
  autoscaling_group_name = aws_autoscaling_group.ASG_WebServers.id
  alb_target_group_arn   = aws_lb_target_group.TargetGroup-WebServers.arn
}


# AWS, Autoscaling Policy (Scaling Options)
/*
https://www.terraform.io/docs/providers/aws/r/autoscaling_policy.html
*/
resource "aws_autoscaling_policy" "AutoScaling_Policy_WebServers" {
  name        = "AutoScaling_Policy_WebServers"
  policy_type = "TargetTrackingScaling"
  # cooldown    = 300 (Cooldown is only supported for policy type SimpleScaling)

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