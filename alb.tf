resource "aws_default_vpc" "default_vpc" {}

resource "aws_default_subnet" "default_subnet_a" {
  availability_zone = "eu-west-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  availability_zone = "eu-west-1b"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name = "db_subnet_group_nest_lambda"
  subnet_ids = [
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id
  ]
}

resource "aws_alb" "application_load_balancer" {
  name               = "nest-ecs-alb"
  load_balancer_type = "application"
  subnets = [
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id
  ]
  security_groups = [aws_security_group.load_balancer_security_group.id]
}

resource "aws_security_group" "load_balancer_security_group" {
  name        = "alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "organization_target_group" {
  name        = "organization-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id # default VPC
  health_check {
    path                = "/organization/health"
    protocol            = "HTTP"
    port                = "3000"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found Test"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "organization_rule" {
  listener_arn = aws_lb_listener.alb_listener.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.organization_target_group.arn
  }
  condition {
    path_pattern {
      values = ["/organization/*"]
    }
  }
}

resource "aws_security_group" "ecs_service_sg" {
  name        = "ecs-service-sg"
  description = "Allow traffic from ALB"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "organization_service" {
  name            = "organization-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.organization_task.arn
  desired_count   = 1

  load_balancer {
    target_group_arn = aws_lb_target_group.organization_target_group.arn
    container_name   = "nest-ecr-organization"
    container_port   = 3000
  }

  network_configuration {
    subnets          = [aws_default_subnet.default_subnet_a.id, aws_default_subnet.default_subnet_b.id]
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = true
  }

  launch_type = "FARGATE"
}

resource "aws_ecs_task_definition" "organization_task" {
  family                   = "nest-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "nest-ecr-organization",
      "image": "${var.container_image}",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nest-ecs",
          "awslogs-region": "eu-west-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
  DEFINITION
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/nest-ecs"
  retention_in_days = 7
}

output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}
