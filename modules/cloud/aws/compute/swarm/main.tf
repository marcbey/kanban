terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
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

resource "aws_instance" "docker-swarm-manager" {
  ami               = "ami-0af9b40b1a16fe700"
  instance_type     = "t3.micro"
  availability_zone = "eu-central-1b"
  key_name          = "swarm-key"
  subnet_id         = data.aws_subnets.main_subnets.ids[0]

  vpc_security_group_ids = [
    aws_security_group.docker-swarm-sg.id,
  ]
  tags = {
    "Name" = "docker-swarm-manager"
  }
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
