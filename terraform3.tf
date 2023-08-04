terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}
provider "aws" {
    region = ""
    access_key = ""
    secret_key = "" 
}

resource "aws_vpc" "mumbai" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "production-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.mumbai.id
    tags = {
        Name = "Production-IGW"
    }
}

resource "aws_route_table" "prodtable" {
    vpc_id = aws_vpc.mumbai.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "prod-table"
    }
}
variable "subnet_prefix" {
    description = "Choose a subnet CIDR Block Range"
}
resource "aws_subnet" "subnet_1" {
    vpc_id = aws_vpc.mumbai.id
    cidr_block = var.subnet_prefix[0].cidr_block
    availability_zone = "ap-south-1a"
    tags = {
        Name = var.subnet_prefix[0].name
    }
}
resource "aws_subnet" "subnet_2" {
    vpc_id            = aws_vpc.mumbai.id
    cidr_block        = var.subnet_prefix[1].cidr_block
    availability_zone = "ap-south-1a"
    tags = {
        Name = var.subnet_prefix[1].name
    }
}
resource "aws_route_table_association" "prodasciate" {
    subnet_id = aws_subnet.subnet_1.id
    route_table_id = aws_route_table.prodtable.id   
}

resource "aws_security_group" "sg1" {
    name = "mumbai_security_group"
    description = "mumbai group description"
    vpc_id = aws_vpc.mumbai.id
    
    ingress {
        description = "http_traffic "
        from_port = 80
        to_port = 80 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    ingress {
        description = "http_traffic "
        from_port = 443
        to_port = 443 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    ingress {
        description = "http_traffic "
        from_port = 22
        to_port = 22 
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    egress {
       from_port        = 0
       to_port          = 0
       protocol         = "-1"
       cidr_blocks      = ["0.0.0.0/0"]
    }
}
resource "aws_network_interface" "web-server" {
  subnet_id       = aws_subnet.subnet_1.id
  private_ips     = ["10.0.0.10"]
  security_groups = [aws_security_group.sg1.id]

}
resource "aws_eip" "public" {
    domain                       = "vpc"
    network_interface         = aws_network_interface.web-server.id
    associate_with_private_ip = "10.0.0.10"
    depends_on                = [aws_internet_gateway.igw]
}

output "server_ip" {
    value = aws_eip.public.public_ip
}

resource "aws_instance" "web_1" {
    ami               = "ami-0f5ee92e2d63afc18"
    instance_type     = "t2.micro"
    availability_zone = "ap-south-1a"
    key_name          = "newpai"   
    network_interface {
        device_index = 0
        network_interface_id = aws_network_interface.web-server.id
    }
    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 mysql-server php php-mysql libapache2-mod-php php-cli -y
                sudo systemctl enable apache2
                sudo systemctl enable apache2
                sudo printf "<?php\nphpinfo();\n?>" > /var/www/html/info.php
                EOF
    tags = {
        Name = "ubuntu-server"
    }
}
output "privateip" {
    value = aws_instance.web_1.private_ip
}


# resource "<provider>_<resource_type>" "name" {
#    config options ...
#    key = "value"
#    key2 = "another_value"
# }
# output "name" {
#    value = "<resource_name>.<logical_name>.<state>"
#}
#variable "<logicalname>" {
#     description = "cidr block for the subnet"
#     #default
#     #type = string
#}
