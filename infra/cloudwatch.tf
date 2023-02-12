resource "aws_cloudwatch_metric_alarm" "cpu_util_alarm_scale_up" {
  alarm_name = "cloudwatch-cpu-util-scale-up"
  metric_name = "CPUUtilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace = "AWS/EC2"
  evaluation_periods = "2"
  period = "120"
  statistic = "Average"
  threshold = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name
  }
  alarm_description = "This metric monitors EC2 CPU Utilization"
  alarm_actions = [aws_autoscaling_policy.avg_cpu_greater_than_50.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu_util_alarm_scale_down" {
  alarm_name = "cloudwatch-cpu-util-scale-down"
  metric_name = "CPUUtilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace = "AWS/EC2"
  evaluation_periods = "2"
  period = "120"
  statistic = "Average"
  threshold = "10"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name
  }
  alarm_description = "This metric monitors EC2 CPU Utilization"
  alarm_actions = [aws_autoscaling_policy.avg_cpu_less_than_50.arn]
}

resource "aws_autoscaling_policy" "avg_cpu_greater_than_50" {
  name = "average_cpu_policy_greater_than_50"
  autoscaling_group_name = aws_autoscaling_group.my_asg.id
  adjustment_type = "ChangeInCapacity"
  

  policy_type = "SimpleScaling"
  scaling_adjustment = 1
  cooldown = "300"
  #policy_type = "StepScaling"
  # metric_aggregation_type = "Average"
  # step_adjustment {
  #   scaling_adjustment = -1
  #   metric_interval_lower_bound = 
  #   metric_interval_upper_bound = 
  # }
  # step_adjustment {
  #   scaling_adjustment = 1
  #   metric_interval_lower_bound = 
  #   metric_interval_upper_bound = 
  # }
}

resource "aws_autoscaling_policy" "avg_cpu_less_than_50" {
  name = "average_cpu_policy_less_than_50"
  autoscaling_group_name = aws_autoscaling_group.my_asg.id
  adjustment_type = "ChangeInCapacity"
  

  policy_type = "SimpleScaling"
  scaling_adjustment = -1
  cooldown = "300"
  #policy_type = "StepScaling"
  # metric_aggregation_type = "Average"
  # step_adjustment {
  #   scaling_adjustment = -1
  #   metric_interval_lower_bound = 
  #   metric_interval_upper_bound = 
  # }
  # step_adjustment {
  #   scaling_adjustment = 1
  #   metric_interval_lower_bound = 
  #   metric_interval_upper_bound = 
  # }
}