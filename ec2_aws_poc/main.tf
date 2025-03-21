
# Configure the AWS Provider
provider "aws" {

}

#variables

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}


# Create a VPC
resource "aws_vpc" "terraform-vpc-demo" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# Create a VPC subnet under the VPC, we will create
resource "aws_subnet" "terraform-subnet-1" {
    vpc_id = aws_vpc.terraform-vpc-demo.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "terraform-gateway" {
  vpc_id = aws_vpc.terraform-vpc-demo.id

  tags = {
    Name = "${var.env_prefix}-gateway"
  }
}

#Use default route table
resource "aws_default_route_table" "terraform-default-rtb" {
  default_route_table_id = aws_vpc.terraform-vpc-demo.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-gateway.id
  }

  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}

# Use default security group
resource "aws_default_security_group" "terraform-default-sg" {
  vpc_id      = aws_vpc.terraform-vpc-demo.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22 // it's a port range, for now it's only for port 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }
}

#Create EC2 instance
#Filter a AMI
data "aws_ami" "latest-ubuntu-linux" {
  most_recent = true
  owners = ["099720109477"] # Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
}
#Provides an EC2 key pair resource
resource "aws_key_pair" "terraform-key-pair" {
  key_name   = "terraform-key-pair"
  public_key = file(var.public_key_location)
  }


#EC2 instance
resource "aws_instance" "web" {
  ami = data.aws_ami.latest-ubuntu-linux.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.terraform-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.terraform-default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.terraform-key-pair.key_name

  #Excute command in the EC2 instance

  user_data = file("entry-script.sh")
  # user_data = <<EOF
#                   #!/bin/bash
#                   sudo apt update -y
#                   sudo snap install docker.io
#                   sudo snap start docker
#                   sudo usermod -aG docker ubuntu
#                   sudo service ssh reload
#                   sudo docker run -p 8080:80 nginx
#               EOF
  tags = {
    Name = "${var.env_prefix}-terraform-demo"
  }
}

# Get the output of the public IP for the EC2 instance

output "public_ip_address" {
  value = aws_instance.web.public_ip
  
}



# output "sg" {
#   value = aws_default_security_group.terraform-default-sg.id
  
# }

# Create security group
# resource "aws_security_group" "terraform-sg" {
#   name        = "terraform-sg"
#   description = "Allow TLS inbound traffic"
#   vpc_id      = aws_vpc.terraform-vpc-demo.id

#   ingress {
#     description      = "TLS from VPC"
#     from_port        = 22 // it's a port range, for now it's only for port 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = [var.my_ip]
#   }
#     ingress {
#     description      = "TLS from VPC"
#     from_port        = 8080
#     to_port          = 8080
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "${var.env_prefix}-sg"
#   }
# }


#Create route-table for VPC
# resource "aws_route_table" "terraform-route-table" {
#   vpc_id = aws_vpc.terraform-vpc-demo.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.terraform-gateway.id
#   }

#   tags = {
#     Name = "${var.env_prefix}-route-table"
#   }
# }
# Associate the route-table we create to subnet

# resource "aws_route_table_association" "a-rtb-subnet" {
#   subnet_id      = aws_subnet.terraform-subnet-1.id
#   route_table_id = aws_route_table.terraform-route-table.id
# }