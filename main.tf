terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
  required_version = ">= 1.1.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_db_subnet_group" "rds" {
  name       = "main"

  subnet_ids = [
    "subnet-019b999ed06f1d9bc",
    "subnet-0bcc62bd4b280730c"
  ]

  tags = {
    Name = "tc-s1-32-subnet-group"
  }
}

data "aws_secretsmanager_secret" "secrets" {
  arn = "arn:aws:secretsmanager:us-east-1:741543006217:secret:rds-secret-rq2LdF"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.secrets.id
}

resource "aws_db_instance" "tc" {
  identifier           = "tc"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "15"
  instance_class       = "db.t3.micro"
  username             = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["username"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["password"]
  parameter_group_name = "default.postgres15"
  vpc_security_group_ids=["sg-011580c646528e145"] 
  db_subnet_group_name = aws_db_subnet_group.rds.name
  skip_final_snapshot  = true
}
