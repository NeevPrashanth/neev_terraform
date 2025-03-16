
# Configure the AWS Provider
provider "aws" {

}

# Create a VPC
resource "aws_vpc" "terraform-vpc-demo" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# Import my own subnet module, give it a name could be any.
module "myapp-subnet"{
  source = "./modules/subnet"
  vpc_id = aws_vpc.terraform-vpc-demo.id
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix  = var.env_prefix
  default_route_table_id = aws_vpc.terraform-vpc-demo.default_route_table_id
}

# Import webserver module
module "myapp-webserver" {
  source = "./modules/webserver"
  vpc_id = aws_vpc.terraform-vpc-demo.id
  my_ip = var.my_ip
  env_prefix = var.env_prefix
  public_key_location = file(var.public_key_location)
  instance_type = var.instance_type
  subnet_id = module.myapp-subnet.subnet.id
  avail_zone = var.avail_zone
}

# Get the output of the public IP for the EC2 instance

output "public_ip_address" {
  value = module.myapp-webserver.public_ip
  
}
