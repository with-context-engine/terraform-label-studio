<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws)

## Modules

The following Modules are called:

### <a name="module_bucket"></a> [bucket](#module\_bucket)

Source: terraform-aws-modules/s3-bucket/aws

Version:

### <a name="module_db"></a> [db](#module\_db)

Source: terraform-aws-modules/rds/aws

Version:

## Resources

The following resources are used by this module:

- [aws_apprunner_service.label_studio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service) (resource)
- [aws_apprunner_vpc_connector.label_studio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_vpc_connector) (resource)
- [aws_iam_policy.app_runner_instance_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
- [aws_iam_policy.app_runner_service_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
- [aws_iam_role.app_runner_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role.app_runner_service_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy_attachment.app_runner_instance_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_iam_role_policy_attachment.app_runner_service_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
- [aws_secretsmanager_secret_version.db_master_user_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_apprunner_label_studio_ecr_image_identifier"></a> [apprunner\_label\_studio\_ecr\_image\_identifier](#input\_apprunner\_label\_studio\_ecr\_image\_identifier)

Description: The URI of the ECR repository for the label studio image. ex: 123456789012.dkr.ecr.us-east-1.amazonaws.com/label-studio:latest

Type: `any`

### <a name="input_apprunner_label_studio_ecr_image_repository_arn"></a> [apprunner\_label\_studio\_ecr\_image\_repository\_arn](#input\_apprunner\_label\_studio\_ecr\_image\_repository\_arn)

Description: value of the ECR repository ARN for the label studio image

Type: `any`

### <a name="input_apprunner_vpc_connector_security_group_ids"></a> [apprunner\_vpc\_connector\_security\_group\_ids](#input\_apprunner\_vpc\_connector\_security\_group\_ids)

Description: The IDs of the security groups for the VPC connector

Type: `list(string)`

### <a name="input_db_security_group_ids"></a> [db\_security\_group\_ids](#input\_db\_security\_group\_ids)

Description: The IDs of the security groups for the database

Type: `list(string)`

### <a name="input_db_subnet_group_name"></a> [db\_subnet\_group\_name](#input\_db\_subnet\_group\_name)

Description: The name of the database subnet group

Type: `any`

### <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids)

Description: The IDs of the subnets

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_apprunner_port"></a> [apprunner\_port](#input\_apprunner\_port)

Description: value of the app runner port

Type: `number`

Default: `8080`

### <a name="input_apprunner_runtime_instance_configuration"></a> [apprunner\_runtime\_instance\_configuration](#input\_apprunner\_runtime\_instance\_configuration)

Description: values of the app runner runtime instance configuration

Type:

```hcl
object({
    cpu    = string
    memory = string
  })
```

Default:

```json
{
  "cpu": "1 vCPU",
  "memory": "2 GB"
}
```

### <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage)

Description: The amount of storage to allocate for the database

Type: `number`

Default: `5`

### <a name="input_db_backup_retaintion_period"></a> [db\_backup\_retaintion\_period](#input\_db\_backup\_retaintion\_period)

Description: The backup retention period for the database

Type: `number`

Default: `1`

### <a name="input_db_backup_window"></a> [db\_backup\_window](#input\_db\_backup\_window)

Description: The backup window for the database

Type: `string`

Default: `"03:00-06:00"`

### <a name="input_db_deletion_protection"></a> [db\_deletion\_protection](#input\_db\_deletion\_protection)

Description: Whether to enable deletion protection for the database

Type: `bool`

Default: `false`

### <a name="input_db_engine"></a> [db\_engine](#input\_db\_engine)

Description: The type of database engine

Type: `string`

Default: `"postgres"`

### <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version)

Description: The version of the database engine

Type: `string`

Default: `"16"`

### <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class)

Description: The instance class for the database

Type: `string`

Default: `"db.t4g.micro"`

### <a name="input_db_maintenance_window"></a> [db\_maintenance\_window](#input\_db\_maintenance\_window)

Description: The maintenance window for the database

Type: `string`

Default: `"Mon:00:00-Mon:03:00"`

### <a name="input_db_major_engine_version"></a> [db\_major\_engine\_version](#input\_db\_major\_engine\_version)

Description: The major version of the database engine

Type: `string`

Default: `"16"`

### <a name="input_db_max_allocated_storage"></a> [db\_max\_allocated\_storage](#input\_db\_max\_allocated\_storage)

Description: The maximum amount of storage to allocate for the database

Type: `number`

Default: `10`

### <a name="input_db_multi_az"></a> [db\_multi\_az](#input\_db\_multi\_az)

Description: value of the database multi az

Type: `bool`

Default: `true`

### <a name="input_db_name"></a> [db\_name](#input\_db\_name)

Description: The name of the database

Type: `string`

Default: `"postgres"`

### <a name="input_db_parameters"></a> [db\_parameters](#input\_db\_parameters)

Description: values of the database parameters

Type:

```hcl
list(object({
    name  = string
    value = string
  }))
```

Default:

```json
[
  {
    "name": "autovacuum",
    "value": "1"
  },
  {
    "name": "client_encoding",
    "value": "utf8"
  },
  {
    "name": "rds.force_ssl",
    "value": "0"
  }
]
```

### <a name="input_db_port"></a> [db\_port](#input\_db\_port)

Description: value of the database port

Type: `number`

Default: `5432`

### <a name="input_db_skip_final_snapshot"></a> [db\_skip\_final\_snapshot](#input\_db\_skip\_final\_snapshot)

Description: Whether to skip the final snapshot for the database

Type: `bool`

Default: `true`

### <a name="input_db_username"></a> [db\_username](#input\_db\_username)

Description: value of the database username

Type: `string`

Default: `"postgres"`

### <a name="input_identifier"></a> [identifier](#input\_identifier)

Description: A unique identifier for the resources

Type: `string`

Default: `"label-studio-on-apprunner"`

## Outputs

The following outputs are exported:

### <a name="output_apprunner_service_arn"></a> [apprunner\_service\_arn](#output\_apprunner\_service\_arn)

Description: The ARN of the App Runner service

### <a name="output_rds_instance_arn"></a> [rds\_instance\_arn](#output\_rds\_instance\_arn)

Description: The ID of the RDS instance

### <a name="output_rds_instance_endpoint"></a> [rds\_instance\_endpoint](#output\_rds\_instance\_endpoint)

Description: The endpoint of the RDS instance

### <a name="output_rds_instance_identifier"></a> [rds\_instance\_identifier](#output\_rds\_instance\_identifier)

Description: The endpoint of the RDS instance

### <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn)

Description: The object of the S3 bucket

### <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name)

Description: The name of the S3 bucket
<!-- END_TF_DOCS -->