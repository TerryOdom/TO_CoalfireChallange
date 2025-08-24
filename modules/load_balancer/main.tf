# ------------------------------------------------------------------
# FILE: modules/load_balancer/main.tf
# ------------------------------------------------------------------

resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = var.asg_name
  lb_target_group_arn   = aws_lb_target_group.main.arn
}


# --- CloudWatch Alarm for Unhealthy Hosts (Improvement #2) ---
# This alarm will notify an operator if the number of healthy instances
# in the target group drops, indicating a potential application issue.
# ------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "unhealthy_hosts" {
  alarm_name          = "${var.project_name}-unhealthy-hosts-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This alarm triggers if there is at least one unhealthy host in the target group."
  
  dimensions = {
    LoadBalancer  = aws_lb.main.name
    TargetGroup = aws_lb_target_group.main.name
  }

  # In a real scenario, you would configure an SNS topic for notifications
  # alarm_actions = [aws_sns_topic.operator_alerts.arn]
}
