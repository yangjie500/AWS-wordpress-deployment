data "aws_ami" "latest_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-hvm-*-gp2"]
  }
  filter {
      name   = "virtualization-type"
      values = ["hvm"]
  }
}

resource "aws_launch_template" "my_launch_template" {
  name = "my_launch_template"
  description = "Simple EC2 launch template for ASG"
  image_id = data.aws_ami.latest_ami.id
  instance_type = var.EC2_type
  #vpc_security_group_ids = [aws_security_group.allow_tls.id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.my_instance_profile.arn
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.allow_tls.id]
  }
  # block_device_mappings {
  #   device_name = "/dev/sda1"
  
  #   ebs {
  #     volume_size = 5
  #     delete_on_termination = true
  #     volume_type = "gp2"
  #   }
  # }
}

resource "aws_lb_target_group" "my_lb_target_group" {
  name = "my-lb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.my_vpc.id
  target_type = "instance"
}

resource "aws_lb" "my_lb" {
  name = "Autoscaling-group-LB"
  internal = false
  load_balancer_type = "application"
  subnets = aws_subnet.my_subnet_public[*].id
  security_groups = [aws_security_group.allow_tls.id]
}

resource "aws_lb_listener" "my_lb_listener" {
  load_balancer_arn = aws_lb.my_lb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.my_lb_target_group.arn
  }
}

resource "aws_autoscaling_group" "my_asg" {
  name = "my-autoscaling-group"
  min_size = 1
  max_size = 2
  desired_capacity = 1
  launch_template {
    id = aws_launch_template.my_launch_template.id
    version = "$Latest"
  } 
  vpc_zone_identifier = aws_subnet.my_subnet_public[*].id
  health_check_grace_period = 300 # Default
  health_check_type = "EC2"
  
  lifecycle {
    ignore_changes = [
      desired_capacity,
      target_group_arns
    ]
  }
  tag {
    key = "Type"
    value = "My-ASG"
    propagate_at_launch = true
  }
  depends_on = [
    aws_ssm_association.my_ssm_association
  ]
}

resource "aws_autoscaling_attachment" "my_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.my_asg.id
  lb_target_group_arn = aws_lb_target_group.my_lb_target_group.arn
}





