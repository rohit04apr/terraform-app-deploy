// Check for the Availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

// Grab the latest ubuntu AMI from the API. We will use this
// when creating a new EC2 Instance.
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

// Manage tags
locals {
  asg_tags = merge({
    Name = "development-web",
  }, var.custom_tags)
}