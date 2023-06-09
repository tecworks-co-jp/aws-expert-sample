# Application Load Balancer
resource "aws_lb" "example" {
  name                       = "YOUR-ALB-NAME"
  load_balancer_type         = "application"
  internal                   = false
  idle_timeout               = 60
  enable_deletion_protection = false

  subnets = [
    aws_subnet.public_0.id,
    aws_subnet.public_1.id,
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }

  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id,
    module.http_redirect_sg.security_group_id,
  ]
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
}

# Security Groups
module "http_sg" {
  source = "./security_group"
  name   = "YOUR-HTTP-SECURITY-GROUP-NAME"
  vpc_id = aws_vpc.example.id
  port   = 80
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

module "https_sg" {
  source = "./security_group"
  name   = "YOUR-HTTPS-SECURITY-GROUP-NAME"
  vpc_id = aws_vpc.example.id
  port   = 443
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

module "http_redirect_sg" {
  source = "./security_group"
  name   = "YOUR-HTTP-REDIRECT-SECURITY-GROUP-NAME"
  vpc_id = aws_vpc.example.id
  port   = 8080
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HTTP response\n"
      status_code  = "200"
    }
  }
}

# HTTPS listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.example.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "HTTPS response\n"
      status_code  = "200"
    }
  }
}

# Redirect HTTP to HTTPS
resource "aws_lb_listener" "redirect_http_to_https" {
  load_balancer_arn = aws_lb.example.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Target group
resource "aws_lb_target_group" "example" {
  name                 = "YOUR-TARGET-GROUP-NAME"
  target_type          = "ip"
  vpc_id               = aws_vpc.example.id
  port                 = 80
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [
    aws_lb.example
  ]
}

# Listener rule
resource "aws_lb_listener_rule" "example" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
