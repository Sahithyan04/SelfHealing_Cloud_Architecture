variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = "terraform"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing AWS key pair name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "Optional VPC ID (if using default, leave null)"
  type        = string
  default     = null
}
