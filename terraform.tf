terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}
provider "aws" {
    region = "ap-south-1"
}
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "company"

    workspaces {
      name = "my-app-prod"
    }
  }
}
variable "prefix" {
    description = "enter here instance types"
}
resource "aws_instance" "web" {
    ami = "ami-0f5ee92e2d63afc18"
    instance_type = var.prefix
    tags = {
        Name = "Web-Server"
    }
}
output "instance-type" {
    value = aws_instance.web.instance_type 
}
output "public-ip" {
    value = aws_instance.web.public_ip
}
output "storage" {
    value = aws_instance.web.root_block_device[0].volume_size
}
output "storage-type" {
    value = aws_instance.web.root_block_device[0].volume_type
}
