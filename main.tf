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
          "ecr:GetAuthorizationToken"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:BatchCheckLayerAvailability"
        ],
        "Resource" : [
          "${var.apprunner_label_studio_ecr_image_repository_arn}"
        ]
      }
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
      image_identifier      = var.apprunner_label_studio_ecr_image_identifier
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

resource "aws_security_group_rule" "allow_app_runner_to_db" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = var.db_security_group_ids[0]
  source_security_group_id = aws_apprunner_vpc_connector.label_studio.security_group_ids[0]
}

module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  bucket = "${var.identifier}-bucket"
  # https://labelstud.io/guide/persistent_storage#Configure-CORS-for-the-S3-bucket
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
      allowed_origins = ["*"]
      expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
      max_age_seconds = 3600
    }
  ]
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.identifier}-db"

  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance_class
  family               = "${var.db_engine}${var.db_engine_version}"
  major_engine_version = var.db_major_engine_version

  db_name                     = var.db_name
  username                    = var.db_username
  port                        = var.db_port
  manage_master_user_password = true
  multi_az                    = var.db_multi_az
  db_subnet_group_name        = var.db_subnet_group_name
  vpc_security_group_ids      = var.db_security_group_ids
  allocated_storage           = var.db_allocated_storage
  max_allocated_storage       = var.db_max_allocated_storage

  maintenance_window = var.db_maintenance_window

  backup_window           = var.db_backup_window
  backup_retention_period = var.db_backup_retaintion_period
  skip_final_snapshot     = var.db_skip_final_snapshot
  deletion_protection     = var.db_deletion_protection

  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  create_cloudwatch_log_group           = true
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  parameters                            = var.db_parameters
}

