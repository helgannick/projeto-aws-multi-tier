# ── Busca a AMI mais recente do Amazon Linux 2023 ────────────────────
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ── Security Group das EC2 ───────────────────────────────────────────
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-${var.environment}-sg-ec2"
  description = "Security Group - EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-sg-ec2"
  }
}

# ── Launch Template ──────────────────────────────────────────────────
resource "aws_launch_template" "main" {
  name_prefix   = "${var.project_name}-${var.environment}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y nginx
    systemctl start nginx
    systemctl enable nginx

    # Página customizada com info da instância
    TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
      -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/instance-id)
    AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
      http://169.254.169.254/latest/meta-data/placement/availability-zone)

    cat > /usr/share/nginx/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head><title>Multi-Tier AWS | Marcos Barbosa</title></head>
    <body style="font-family:Arial; text-align:center; padding:50px; background:#f0f0f0;">
      <h1>🚀 Infraestrutura Multi-Tier na AWS</h1>
      <h2>Projeto: Cloud Engineer Portfolio</h2>
      <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
      <p><strong>Availability Zone:</strong> $AZ</p>
      <p><strong>Provisionado com Terraform + Auto Scaling</strong></p>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-ec2"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ── Auto Scaling Group ───────────────────────────────────────────────
resource "aws_autoscaling_group" "main" {
  name                = "${var.project_name}-${var.environment}-asg"
  desired_capacity    = var.asg_desired
  min_size            = var.asg_min
  max_size            = var.asg_max
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = [var.target_group_arn]
  health_check_type   = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-asg"
    propagate_at_launch = true
  }
}

# ── Políticas de Auto Scaling ────────────────────────────────────────
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project_name}-${var.environment}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project_name}-${var.environment}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}