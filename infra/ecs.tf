resource "aws_ecs_cluster" "web-ecs" {
  name = "webapp-cluster"

}

resource "aws_ecs_service" "webapp" {
  name            = "webapp-django"
  cluster         = aws_ecs_cluster.web-ecs.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.webapp.arn
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
    security_groups  = [aws_security_group.ecs-fargate.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.default-target-group.arn
    container_name   = "webapp"
    container_port   = 8000
  }
}

resource "aws_ecs_task_definition" "webapp" {
  family                   = "webapp"
  requires_compatibilities = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
  }
  network_mode       = "awsvpc"
  cpu                = 256
  memory             = 512
  execution_role_arn = aws_iam_role.ecs-task-execution-role.arn
  task_role_arn      = aws_iam_role.ecs-task-execution-role.arn
  container_definitions = jsonencode([{
    name : "webapp"
    cpu : 256
    memory : 512
    image : "${aws_ecr_repository.webapp.repository_url}:latest"
    essential : true
    portMappings : [{ containerPort : 8000, protocol : "tcp" }]
    command : ["gunicorn", "-b", ":8000", "terracantus.wsgi:application"]
    environment : [{ name : "DATABASE_URL", value : "${local.db_url}" }]
    logConfiguration : {
      logDriver : "awslogs",
      options : {
        "awslogs-group" : "/ecs/webapp",
        "awslogs-region" : "us-east-1",
        "awslogs-stream-prefix" : "webapp-log-stream"
      }
    }
  }])
  depends_on = [aws_db_instance.postgresql]
}

resource "aws_cloudwatch_log_group" "webapp-log-group" {
  name              = "/ecs/webapp"
  retention_in_days = 30
}

resource "aws_iam_role" "ecs-task-execution-role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : [
            "ecs-tasks.amazonaws.com"
          ]
        },
        "Effect" : "Allow"
      }
    ]
  })
}
resource "aws_iam_role_policy" "ecs-task-execution-role-policy" {
  name = "ecs_task_execution_role_policy"
  role = aws_iam_role.ecs-task-execution-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:DescribeTasks",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeFileSystems"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role" "ecs-service-role" {
  name = "ecs_service_role"
  assume_role_policy = jsonencode({
    "Version" : "2008-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : [
            "ecs-tasks.amazonaws.com"
          ]
        },
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs-service-role-policy" {
  name = "ecs_service_role_policy"
  role = aws_iam_role.ecs-service-role.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeFileSystems"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })
}