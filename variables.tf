variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "instance_count" {
  description = "Number of EC2 instances"
  type        = number
}

variable "instance_name_prefix" {
  description = "Prefix for instance Name tag"
  type        = string
}

variable "key_name" {
  description = "Key Pair Name"
  type        = string
}

variable "public_key_path" {
  description = "Path to public key file"
  type        = string
}