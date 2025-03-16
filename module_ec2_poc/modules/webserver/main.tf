# Use default security group
resource "aws_default_security_group" "terraform-default-sg" {
  vpc_id = var.vpc_id

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
  public_key = var.public_key_location
  }

#EC2 instance
resource "aws_instance" "web" {
  ami = data.aws_ami.latest-ubuntu-linux.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id 
  vpc_security_group_ids = [aws_default_security_group.terraform-default-sg.id]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.terraform-key-pair.key_name

  #Excute command in the EC2 instance
  user_data = file("./modules/webserver/entry-script.sh")
  tags = {
    Name = "${var.env_prefix}-terraform-demo"
  }
}