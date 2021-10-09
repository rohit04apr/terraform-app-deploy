// Security group for ALB.
resource "aws_security_group" "alb_allow_http" {
  name        = "alb-development"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.development.id

  tags = merge({
    Name = "development"
  }, var.custom_tags)

}

// Allow http traffic
resource "aws_security_group_rule" "http_ingress" {
  security_group_id = aws_security_group.alb_allow_http.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  description       = "HTTPS incoming traffic"
  cidr_blocks       = ["0.0.0.0/0"]
}

// Restrict ALB http traffic to ec2 node only
resource "aws_security_group_rule" "http_egress" {
  security_group_id        = aws_security_group.alb_allow_http.id
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "Allow to connect to the instance"
  source_security_group_id = aws_security_group.allow_inbound_http.id
}

// Application Load Balancer
resource "aws_lb" "alb" {
  name               = "development"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups = [
    aws_security_group.alb_allow_http.id
  ]

  subnets = [aws_subnet.public_1.id, aws_subnet.public_2.id]

}

// Target Group
resource "aws_lb_target_group" "alb_tg" {
  name     = "development"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.development.id
}

// ALB Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}
