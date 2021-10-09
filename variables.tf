variable "aws" {
  description = "(Required) Details about this AWS account"
  type        = map(string)

  default = {
    // IAM credentials for the AWS account
    access_key = ""
    secret_key = ""
    // the region for this environment
    region = "eu-central-1"
  }
}

variable "vpc" {
  description = "VPC configuration details"
  type        = map(string)
  default = {
    vpc_cidr         = "10.0.0.0/16",
    subnet_private_1 = "10.0.1.0/24"
    subnet_private_2 = "10.0.2.0/24"
    subnet_public_1  = "10.0.3.0/24"
    subnet_public_2  = "10.0.4.0/24"
  }
}

variable "instance" {
  description = "Launch Configuration details"
  type        = map(string)
  default = {
    instance_type    = "t2.micro",
    root_volume_size = 8
    logs_volume_size = 8
    as_min_size      = 1
    as_max_size      = 2
  }
}
variable "custom_tags" {
  description = "Custom tags which can be passed on to the AWS resources. They should be key value pairs having distinct keys."
  type        = map(string)
  default = {
    Environment = "development",
    CreatedBy   = "terraform"
  }
}

variable "key_path" {
  type        = string
  description = "(Required) Public key path"
  // Provide the path of your .pub file
  default = "/Users/rohit_tiwari 1/.ssh/id_rsa.pub"
}