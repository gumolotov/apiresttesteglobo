provider "aws" {
  region = "us-east-1"
}

resource "aws_ecs_cluster" "api_cluster" {
  name = "api-cluster"
}

resource "aws_ecr_repository" "api_repository" {
  name = "api-comentarios"
}

resource "aws_ecs_task_definition" "api_task" {
  family                   = "api-comentarios-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::339712833448:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([
    {
      name      = "api-comentarios"
      image     = "${aws_ecr_repository.api_repository.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-restapi-globo"
  acl    = "private"
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}



resource "aws_instance" "mongo_instance" {
  ami                    = "ami-071226ecf16aa7d96"  # Substitua pela AMI de sua preferência
  instance_type           = "t2.micro"  # Substitua pelo tipo de instância desejado
  key_name                = "restapi"  # Substitua pela chave SSH que você vai usar

  tags = {
    Name = "MongoDB Instance"
  }

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt install -y mongodb
                sudo systemctl start mongodb
                sudo systemctl enable mongodb
              EOF
}


