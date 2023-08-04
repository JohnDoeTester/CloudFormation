terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}
provider "aws" {
  region = "ap-south-1"
}
variable "instance_type" {
    description = "choose instance type"
    type        = string
}
locals {
    project_name = "Server"
}
resource "aws_instance" "instance" {
  ami           = "ami-0f5ee92e2d63afc18"
  instance_type = var.instance_type
  key_name      = "newpai"
  tags = {
    Name = "Production-${local.project_name}"
  }
}
output "private_ip" {
  value = aws_instance.instance.private_ip
}
output "public_ip" {
  value = aws_instance.instance.public_ip
}
output "state" {
  value = aws_instance.instance.instance_state
}
output "volumesize" {
  value = aws_instance.instance.root_block_device[0].volume_size
}
