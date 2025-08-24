# ------------------------------------------------------------------
# FILE: modules/compute/main.tf
# ------------------------------------------------------------------

# --- IAM Role for SSM (Improvement #1) ---
# This role allows instances to be managed by AWS Systems Manager
# without needing SSH keys.
# ------------------------------------------------------------------
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}


# --- Data source for latest Amazon Linux AMI ---
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- Management (Bastion) Host ---
resource "aws_instance" "mgmt" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  subnet_id     = var.mgmt_subnet_id
  key_name      = var.key_name
  vpc_security_group_ids = [var.mgmt_security_group_id]
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-mgmt-host"
  }
}

# --- Application Auto Scaling Group ---
# User data script to install Apache
data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-app"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  user_data     = base64encode(data.template_file.user_data.rendered)

  vpc_security_group_ids = [var.app_security_group_id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  tags = {
    Name = "${var.project_name}-app-launch-template"
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-app-asg"
  min_size            = 2
  max_size            = 6
  desired_capacity    = 2
  vpc_zone_identifier = var.app_subnet_ids

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-app-instance"
    propagate_at_launch = true
  }
}
