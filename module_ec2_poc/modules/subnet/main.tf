# Create a VPC subnet under the VPC, we will create
resource "aws_subnet" "terraform-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "terraform-gateway" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env_prefix}-gateway"
  }
}

#Use default route table
resource "aws_default_route_table" "terraform-default-rtb" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-gateway.id
  }

  tags = {
    Name = "${var.env_prefix}-route-table"
  }
}
