resource "aws_vpc" "said-work-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Said Work VPC"
  }
}

resource "aws_subnet" "said-work-subnet" {
  vpc_id     = aws_vpc.said-work-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Said Work Subnet"
  }
}

resource "aws_internet_gateway" "said-work-gateway" {
  vpc_id = aws_vpc.said-work-vpc.id

  tags = {
    Name = "Said Work Gatwway"
  }
}

resource "aws_route_table" "said-work-route-table" {
  vpc_id = aws_vpc.said-work-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.said-work-gateway.id
  }

  tags = {
    Name = "Said Work Route"
  }
}

resource "aws_route_table_association" "subnet-route-table-association" {
  subnet_id      = aws_subnet.said-work-subnet.id
  route_table_id = aws_route_table.said-work-route-table.id
}

resource "aws_security_group" "said-work-security-group" {
  name        = "said-work-security-group"
  description = "Allow SSH inbound"
  vpc_id      = aws_vpc.said-work-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aula-02-sg"
  }
}

resource "aws_key_pair" "said_key" {
  key_name   = "said_key"
  public_key = file("~/.ssh/terraform-ec2-key.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Ubuntu / Canonical owner ID
}

resource "aws_instance" "web" {
  count                         = 3
  ami                           = data.aws_ami.ubuntu.id
  instance_type                 = "t2.micro"
  key_name                      = aws_key_pair.said_key.key_name
  subnet_id                     = aws_subnet.said-work-subnet.id
  vpc_security_group_ids        = [aws_security_group.said-work-security-group.id]
  associate_public_ip_address   = true
  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt upgrade

    sudo apt install -y openjdk-17-jdk apache2

    sudo systemctl enable apache2
    sudo systemctl start apache2
  EOF

  tags = {
    Name = "WebServer-${count.index}"
  }
}