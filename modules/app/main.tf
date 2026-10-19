data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

locals {
  instance_tags = {
    Name        = "${var.project_name}-${var.environment}-app"
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
  }
}

resource "aws_iam_role" "app" {
  name = "${var.project_name}-${var.environment}-app-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.project_name}-${var.environment}-app-ssm"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_name}-${var.environment}-app"
  role = aws_iam_role.app.name

  tags = {
    Name = "${var.project_name}-${var.environment}-app"
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    environment = var.environment
  }))

  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  block_device_mappings {
    device_name = data.aws_ami.amazon_linux.root_device_name

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = 8
      volume_type           = "gp3"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.instance_tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.instance_tags
  }

  depends_on = [aws_iam_role_policy_attachment.ssm]

  tags = {
    Name = "${var.project_name}-${var.environment}-app"
  }
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.project_name}-${var.environment}-app"
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [var.target_group_arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300
  default_cooldown          = 300

  launch_template {
    id      = aws_launch_template.app.id
    version = aws_launch_template.app.latest_version
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 300
      skip_matching          = true
    }
  }

  dynamic "tag" {
    for_each = local.instance_tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.project_name}-${var.environment}-app-cpu"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 50

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}
