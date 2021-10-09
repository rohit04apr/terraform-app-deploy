data "template_file" "cloud_config" {
  template = file("${path.module}/templates/cloud-config.yaml")

}

resource "aws_launch_configuration" "lc" {

  name          = "development-lc"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance.instance_type
  key_name      = aws_key_pair.key.id
  security_groups = [
    aws_security_group.allow_inbound_http.id
  ]

  user_data = data.template_file.cloud_config.rendered

  root_block_device {
    encrypted             = true
    volume_type           = "gp2"
    volume_size           = var.instance.root_volume_size
    delete_on_termination = true
  }

  // /var/log volume
  ebs_block_device {
    device_name           = "/dev/xvdf"
    volume_size           = var.instance.logs_volume_size
    volume_type           = "gp2"
    delete_on_termination = true // Change this to false so that you don't loose data
    encrypted             = true
  }

}

resource "aws_autoscaling_group" "as" {
  name = "development-as"

  vpc_zone_identifier = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id
  ]

  launch_configuration = aws_launch_configuration.lc.id
  target_group_arns    = [aws_lb_target_group.alb_tg.id]

  min_size = var.instance.as_min_size
  max_size = var.instance.as_max_size

  dynamic "tag" {
    for_each = local.asg_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }


}

// Monitoring
// Scaling Policies : It will automatically scale up/down nodes on the basis of load
resource "aws_autoscaling_policy" "cpu_scale_in" {
  name                   = "development-scale-in"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.as.name

}

resource "aws_cloudwatch_metric_alarm" "example-cpu-alarm" {
  alarm_name          = "development-cpu-alarm-scaleup"
  alarm_description   = "development-cpu-alarm-scaleup"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.as.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.cpu_scale_in.arn]
}

resource "aws_autoscaling_policy" "cpu_scale_out" {
  name                   = "development-scale-out"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.as.name

}

resource "aws_cloudwatch_metric_alarm" "cpu-alarm-scaledown" {
  alarm_name          = "development-cpu-alarm-scaledown"
  alarm_description   = "development-cpu-alarm-scaledown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.as.name
  }

  actions_enabled = true
  alarm_actions   = [aws_autoscaling_policy.cpu_scale_out.arn]
}

// Monitoring : Cloudwatch will turn red if Application is not available
resource "aws_cloudwatch_metric_alarm" "HealthyHostCount" {
  alarm_name          = "development-healthy-host"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Maximum"
  threshold           = "1"
  alarm_description   = "No Healthy Hosts"
  alarm_actions       = []
  ok_actions          = []
  actions_enabled     = true

  dimensions = {
    "TargetGroup"  = aws_lb_target_group.alb_tg.arn_suffix
    "LoadBalancer" = aws_lb.alb.arn_suffix
  }
}