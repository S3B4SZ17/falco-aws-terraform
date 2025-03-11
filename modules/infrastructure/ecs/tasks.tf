data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

resource "aws_security_group" "aws_events" {
  count       = var.deploy_web_app ? 1 : 0
  name        = "aws-events_security_group"
  description = "aws-events security group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.deploy_web_app ? [1] : []
    content {
      description     = "Allow ${"falco"} port"
      from_port       = 3000
      to_port         = 3000
      protocol        = "tcp"
      security_groups = [length(module.alb) > 0 ? module.alb[0].security_group_id : null]
    }

  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    # cidr_blocks      = [data.aws_vpc.selected.cidr_block]
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = local.tags
}

resource "aws_service_discovery_http_namespace" "aws_events" {
  count       = var.deploy_web_app ? 1 : 0
  name        = "falco"
  description = "CloudMap namespace for ${"falco"}"
  tags        = local.tags
}

resource "aws_ecs_task_definition" "aws_events" {
  family = "falco"

  # Enables a side container for the ecs task
  pid_mode = "task"
  # role that allows ECS to spin up your task, for example needs permission to ECR to get container image
  execution_role_arn = aws_iam_role.aws_events_exec_assume.arn
  # role that your workload gets to access AWS APIs
  task_role_arn = aws_iam_role.aws_events_exec_role.arn

  cpu                      = "1024"
  memory                   = "2048"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  volume {
    name = "falco-config"
  }

  container_definitions = jsonencode([
    {
      name      = "falco"
      image     = "falcosecurity/falco:0.85.1"
      essential = true
      mountPoints = [
        {
          sourceVolume  = "falco-config"
          containerPath = "/etc/falco"
        },
        {
          "containerPath" : "/host/var/run/docker.sock",
          "sourceVolume" : "docker-socket"
        },
        {
          "containerPath" : "/host/dev",
          "sourceVolume" : "dev-fs"
        },
        {
          "containerPath" : "/host/proc",
          "sourceVolume" : "proc-fs",
          "readOnly" : true
        },
        {
          "containerPath" : "/host/boot",
          "sourceVolume" : "boot-fs",
          "readOnly" : true
        },
        {
          "containerPath" : "/host/lib/modules",
          "sourceVolume" : "lib-modules",
          "readOnly" : true
        },
        {
          "containerPath" : "/host/usr",
          "sourceVolume" : "usr-fs",
          "readOnly" : true
        },
        {
          "containerPath" : "/host/etc",
          "sourceVolume" : "etc-fs",
          "readOnly" : true
        }
      ],
      dependsOn = [
        {
          containerName = "falco-config"
          condition     = "COMPLETE"
        }
      ]
    },
    {
      name      = "falco-config"
      image     = "bash"
      essential = false
      command = [
        "sh",
        "-c",
        "echo $FALCO_CONFIG | base64 -d - | tee /etc/falco/falco.yaml; echo $CLOUDTRAIL_RULES | base64 -d - | tee /etc/falco/aws_cloudtrail_rules.yaml"
      ],
      environment = [
        {
          name  = "FALCO_CONFIG"
          value = base64encode(file("falco/falco.yaml"))
        },
        {
          name  = "CLOUDTRAIL_RULES"
          value = base64encode(file("falco/aws_cloudtrail_rules.yaml"))
        }
      ],
      mountPoints = [
        {
          sourceVolume  = "falco-config"
          containerPath = "/etc/falco"
        }
      ],
    },
    {
      name      = "falcosidekick",
      image     = "falcosecurity/falcosidekick:2.31.1",
      essential = true,
      cpu       = 2,
      memory    = 126,
      portMappings = [
        {
          "containerPort" : 2801,
          "hostPort" : 2801,
          "protocol" : "tcp"
        }
      ]
    }
  ])

  tags = local.tags
}

resource "aws_ecs_service" "aws_events" {
  count = var.deploy_web_app ? 1 : 0
  name  = "falco"

  cluster          = module.ecs.cluster_id
  task_definition  = aws_ecs_task_definition.aws_events.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = [aws_security_group.aws_events[0].id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = length(module.alb) > 0 ? module.alb[0].target_groups : null # Ref to https://stackoverflow.com/questions/56742157/unable-to-assume-role-and-validate-the-specified-targetgrouparn
    container_name   = "falco"
    container_port   = 3000
  }

  service_connect_configuration {
    enabled   = true
    namespace = aws_service_discovery_http_namespace.aws_events[0].arn
    service {
      client_alias {
        port     = 3000
        dns_name = "falco"
      }
      port_name      = "falco"
      discovery_name = "falco"
    }

    log_configuration {
      log_driver = "awslogs"
      options = {
        awslogs-create-group  = true
        awslogs-group         = "fargate_logs",
        awslogs-region        = data.aws_region.current.name,
        awslogs-stream-prefix = "svc",
      }
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "aws_events_exec_role" {
  name                = "hunter404"
  assume_role_policy  = data.aws_iam_policy_document.aws_events_exec_role.json
  description         = "Task IAM role for ${"falco"}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  inline_policy {
    name = "allowAWS-events"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:PutLogEvents", "logs:CreateLogStream", "logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          Action = [
            "ses:*",
            "sns:*",
            "iam:*"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
            "ssm:GetParameters"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = local.tags
}

data "aws_iam_policy_document" "aws_events_exec_role" {

  statement {
    sid = "ECSTasksAssumeRole"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"]
    }

  }
}

resource "aws_iam_role" "aws_events_exec_assume" {
  name                = "${"falco"}-exec-assume"
  assume_role_policy  = data.aws_iam_policy_document.aws_events_exec_assume.json
  description         = "Task IAM role for ${"falco"}"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
  inline_policy {
    name = "execAssume"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["logs:PutLogEvents", "logs:CreateLogStream", "logs:CreateLogGroup"]
          Effect   = "Allow"
          Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          Action = ["ecr:GetDownloadUrlForLayer",
            "ecr:GetAuthorizationToken",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability"
          ]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action = [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
            "ssm:GetParameters"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ssm:*:*:parameter/*"
        },
        {
          Action   = ["secretsmanager:GetSecretValue"]
          Effect   = "Allow"
          Resource = "arn:aws:secretsmanager:*:*:secret:*"
        }
      ]
    })
  }

  tags = local.tags
}

data "aws_iam_policy_document" "aws_events_exec_assume" {

  statement {
    sid = "execAssume"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

  }
}

# Cloudwatch log groups config
resource "aws_cloudwatch_log_group" "aws_events" {
  name_prefix       = "/aws/ecs/aws_events"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "instrumented_logs" {
  name_prefix       = "/aws/ecs/instrumented_logs"
  retention_in_days = 7

  tags = local.tags
}
