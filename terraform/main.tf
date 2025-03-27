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
  execution_role_arn       = "arn:aws:iam::<AWS_ACCOUNT_ID>:role/ecsTaskExecutionRole"

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

resource "aws_ecs_service" "api_service" {
  name            = "api-comentarios"
  cluster         = aws_ecs_cluster.api_cluster.id
  task_definition = aws_ecs_task_definition.api_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets = ["subnet-xxxxxx"]
    security_groups = ["sg-xxxxxx"]
  }
}
