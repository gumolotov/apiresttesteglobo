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
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = "arn:aws:iam::339712833448:role/restapi-ecs-task-role"

  container_definitions = jsonencode([
    {
      name      = "api-comentarios"
      image     = "${aws_ecr_repository.api_repository.repository_url}:latest"
      essential = true
      portMappings = [{ containerPort = 80, hostPort = 80 }]
    },
    {
      name  = "prometheus"
      image = "prom/prometheus"
      portMappings = [{ containerPort = 9090, hostPort = 9090 }]
    },
    {
      name  = "grafana"
      image = "grafana/grafana"
      portMappings = [{ containerPort = 3000, hostPort = 3000 }]
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

# Criando Security Group para o Load Balancer
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id

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
}

# Criando o Application Load Balancer
resource "aws_lb" "ecs_alb" {
  name               = "ecs-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets           = ["subnet-082cfefbc739f24b4", "subnet-01f6e009cec9021d9"] # Ajuste conforme sua infraestrutura

  enable_deletion_protection = false
}

# Criando o Target Group para as Tasks do ECS
resource "aws_lb_target_group" "ecs_tg" {
  name     = "ecs-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip" # Necessário para ECS Fargate
}

# Criando Listener para rotear tráfego para ECS
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

# Associando o Target Group ao ECS Service
resource "aws_ecs_service" "ecs_service" {
  name            = "api-comentarios"
  cluster         = "api-cluster"
  task_definition = "api-comentarios-task"
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = ["subnet-082cfefbc739f24b4", "subnet-01f6e009cec9021d9"]  # Substitua pelos IDs das suas subnets
    security_groups = ["sg-0f6507adfb717958a"]  # Substitua pelo seu ID de Security Group
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = "api-comentarios"
    container_port   = 80
  }
}

# Output do DNS do Load Balancer
output "alb_dns_name" {
  value = aws_lb.ecs_alb.dns_name
}