terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_sensitive_file" "private_key" {
  filename        = var.private_key_path
  content         = tls_private_key.rsa.private_key_pem
  file_permission = "0400"
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "swarm-key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_security_group" "docker-swarm-sg" {
  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = null
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
  }, ]

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = null
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = null
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
    {
      cidr_blocks = [
        "0.0.0.0/0",
      ]
      description      = null
      from_port        = 4000
      to_port          = 4000
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
    }
  ]

  tags = {
    "Name" = "docker-swarm-sg"
  }

  region                 = "eu-central-1"
  revoke_rules_on_delete = false
  vpc_id                 = data.aws_vpc.main.id
}

resource "aws_instance" "docker-swarm-node" {
  ami                  = data.aws_ami.amazon_linux_docker.id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.main_profile.name
  key_name             = aws_key_pair.deployer_key.key_name
  count                = var.number_of_nodes
  subnet_id = data.aws_subnets.main_subnets.ids[
    count.index % length(data.aws_subnets.main_subnets.ids)
  ]

  vpc_security_group_ids = [
    aws_security_group.docker-swarm-sg.id,
  ]

  tags = {
    "Name" = "docker-swarm-node"
  }

  user_data = <<-EOF
    #!/usr/bin/env bash
    docker swarm init
  EOF
}

data "aws_vpc" "main" {
  filter {
    name   = "isDefault"
    values = ["true"]
  }
}

data "aws_subnets" "main_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

data "aws_ami" "amazon_linux_docker" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amazon-linux-docker*"]
  }
  owners = ["882873537464"]
}
