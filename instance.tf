
// Create a new security group that allows inbound/outbound http requests
resource "aws_security_group" "allow_inbound_http" {
  name        = "ec2-development"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.development.id

  tags = merge({
    Name = "development"
  }, var.custom_tags)

}

// Allow http from ALB
resource "aws_security_group_rule" "instance_http_ingress" {
  security_group_id        = aws_security_group.allow_inbound_http.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  description              = "HTTPS incoming traffic from alb"
  source_security_group_id = aws_security_group.alb_allow_http.id
}

// Include this sg to the jump server so that it can connect to all private nodes
// Connectivity only allowd within nodes
resource "aws_security_group_rule" "instance_ssh_ingress" {
  security_group_id        = aws_security_group.allow_inbound_http.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  description              = "SSH connectivity from bastion server"
  source_security_group_id = aws_security_group.allow_inbound_http.id
}

// Outbound traffic
resource "aws_security_group_rule" "instance_http_egress" {
  security_group_id = aws_security_group.allow_inbound_http.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  description       = "Allow outbound traffic"
  cidr_blocks       = ["0.0.0.0/0"]
}

// Key pair for ssh
resource "aws_key_pair" "key" {
  key_name   = "development"
  public_key = file(var.key_path)

}

