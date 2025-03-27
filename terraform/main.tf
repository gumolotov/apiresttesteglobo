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
  execution_role_arn       = "arn:aws:iam::339712833448:role/restapi-ecs-task-role"

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

resource "aws_iam_role" "restapi" {
  name = "restapi-ecs-task-role"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
})
}

resource "aws_iam_policy_attachment" "ecs_task_execution" {
  name       = "restapi"
  roles      = [aws_iam_role.restapi.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "api-comentarios" {
  name            = "api-comentarios"
  cluster         = aws_ecs_cluster.api_cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["subnet-082cfefbc739f24b4", "subnet-01f6e009cec9021d9"]  # Substitua pelos IDs das suas subnets
    security_groups = ["sg-0f6507adfb717958a"]  # Substitua pelo seu ID de Security Group
    assign_public_ip = true
  }
}






