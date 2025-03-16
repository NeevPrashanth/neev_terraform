
# Configure the AWS Provider
# provider "aws" {

# }
#variables

variable "cidr_block" {
    description = "subnet cidr block"
    # default = "172.10.20.0/24"
    type = list(object({
        cidr_block = string
        name = string
    }))
}

# variable "environment" {
#     description = "deployment environment"
#     type = string
# }

# Create a VPC
resource "aws_vpc" "terraform-vpc-demo" {
  cidr_block = var.cidr_block[0].cidr_block
  tags = {
    Name = var.cidr_block[0].name
  }
}

# Create a VPC subnet under the VPC, we will create
resource "aws_subnet" "terraform-subnet-1" {
    vpc_id = aws_vpc.terraform-vpc-demo.id
    cidr_block = var.cidr_block[1].cidr_block
    availability_zone = "ap-southeast-2a"
    tags = {
    Name = var.cidr_block[1].name
  }
}
# # output value of the resource

# output "terraform-vpc-id" {
#     value = aws_vpc.terraform-vpc-demo.id
  
# }

# output "terraform-vpc-arn" {
#     value = aws_vpc.terraform-vpc-demo.arn
  
# }

# output "terraform-subnet-id" {
#     value = aws_subnet.terraform-subnet-1.id
  
# }

# # Create a VPC subnet under an exist VPC
# data "aws_vpc" "exist" {
#      default = true
# }

# resource "aws_subnet" "terraform-subnet-2" {
#     vpc_id = data.aws_vpc.exist.id
#     cidr_block = "172.31.48.0/20"
#     availability_zone = "ap-southeast-2b"
#     tags = {
#     Name = "terraform-subnet-2"
#   }
# }