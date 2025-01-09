
resource "aws_iam_role" "app_runner_service_role" {
  name = "${var.identifier}-app-runner-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "build.apprunner.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_policy" "app_runner_service_policy" {
  name        = "${var.identifier}-app-runner-service-policy"
  description = "Policy for App Runner service"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource" : [
          "${aws_ecr_repository.label_studio_image_repository.arn}"
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_runner_service_policy_attachment" {
  role       = aws_iam_role.app_runner_service_role.name
  policy_arn = aws_iam_policy.app_runner_service_policy.arn
}


resource "aws_iam_role" "app_runner_instance_role" {
  name = "${var.identifier}-app-runner-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "tasks.apprunner.amazonaws.com",
        },
        Action = "sts:AssumeRole",
      },
    ],
  })
}

resource "aws_iam_policy" "app_runner_instance_role_policy" {
  name = "${var.identifier}-app-runner-instance-role-policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt*",
          "ssm:GetParameters"
        ],
        "Resource" : [
          "*",
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "${module.bucket.s3_bucket_arn}",
          "${module.bucket.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "app_runner_instance_role_policy_attachment" {
  role       = aws_iam_role.app_runner_instance_role.name
  policy_arn = aws_iam_policy.app_runner_instance_role_policy.arn
}

data "aws_secretsmanager_secret_version" "db_master_user_password" {
  secret_id = module.db.db_instance_master_user_secret_arn
}

locals {
  db_password = jsondecode(data.aws_secretsmanager_secret_version.db_master_user_password.secret_string)["password"]
}

resource "aws_apprunner_service" "label_studio" {
  service_name = "${var.identifier}-app-runner-service"

  source_configuration {
    auto_deployments_enabled = true
    image_repository {
      image_configuration {
        port          = var.apprunner_port
        start_command = "label-studio start my_project --init -db postgresql --username ${module.db.db_instance_username} --password ${local.db_password}"
        runtime_environment_variables = {
          USE_ENFORCE_CSRF_CHECKS = "false"
          DEBUG                   = "true"
          DJANGO_DB               = "default"
          POSTGRE_USER            = module.db.db_instance_username
          POSTGRE_NAME            = module.db.db_instance_name
          POSTGRE_HOST            = module.db.db_instance_address
          POSTGRE_PORT            = module.db.db_instance_port
          POSTGRE_PASSWORD        = local.db_password
        }
      }
      image_identifier      = "${aws_ecr_repository.label_studio_image_repository.repository_url}:latest"
      image_repository_type = "ECR"
    }
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_service_role.arn
    }
  }

  health_check_configuration {
    timeout  = 20
    interval = 20
  }

  instance_configuration {
    cpu               = var.apprunner_runtime_instance_configuration.cpu
    memory            = var.apprunner_runtime_instance_configuration.memory
    instance_role_arn = aws_iam_role.app_runner_instance_role.arn
  }

  network_configuration {
    egress_configuration {
      egress_type       = "VPC"
      vpc_connector_arn = aws_apprunner_vpc_connector.label_studio.arn
    }
  }
}

resource "aws_apprunner_vpc_connector" "label_studio" {
  vpc_connector_name = "${var.identifier}-vpc-connector"
  subnets            = var.subnet_ids
  security_groups    = var.apprunner_vpc_connector_security_group_ids
}
