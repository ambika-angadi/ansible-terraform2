terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-central-1"
  profile = "techstarter"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "TF VPC"
  }
}

resource "aws_security_group" "sg" {
  name        = "ansible_instance_sg"
  description = "Allow SSH, HTTP inbound traffic"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "kp" {
  key_name   = "id_rsa"
  public_key = file("//wsl.localhost/Debian/home/ambika/.ssh/id_rsa.pub")
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "amazon" {
  ami             = "ami-065ab11fbd3d0323d"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.name]
  key_name        = aws_key_pair.kp.key_name
}

resource "aws_instance" "ubuntu" {
  ami             = "ami-06dd92ecc74fdfb36"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sg.name]
  key_name        = aws_key_pair.kp.key_name
}

output "ec2_ip" {
  value = aws_instance.amazon.public_ip
}

output "ec2_ip1" {
  value = aws_instance.ubuntu.public_ip
}