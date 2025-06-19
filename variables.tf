
#################
# Common Variables
#################
variable "identifier" {
  description = "A unique identifier for the resources"
  default     = "label-studio-on-apprunner"
}

variable "subnet_ids" {
  description = "The IDs of the subnets"
  type        = list(string)
}

#################
# AppRunner Variables
#################
variable "apprunner_label_studio_ecr_image_repository_arn" {
  description = "value of the ECR repository ARN for the label studio image"
}

variable "apprunner_label_studio_ecr_image_identifier" {
  description = "The URI of the ECR repository for the label studio image. ex: 123456789012.dkr.ecr.us-east-1.amazonaws.com/label-studio:latest"
}

variable "apprunner_port" {
  description = "value of the app runner port"
  default     = 8080
}

variable "apprunner_runtime_instance_configuration" {
  description = "values of the app runner runtime instance configuration"
  type = object({
    cpu    = string
    memory = string
  })
  default = {
    cpu    = "1 vCPU"
    memory = "2 GB"
  }
}

variable "apprunner_vpc_connector_security_group_ids" {
  description = "The IDs of the security groups for the VPC connector"
  type        = list(string)
}

#################
# RDS Variables
#################
variable "db_name" {
  description = "The name of the database"
  default     = "postgres"
}

variable "db_username" {
  description = "value of the database username"
  default     = "postgres"
}

variable "db_port" {
  description = "value of the database port"
  default     = 5432
}

variable "db_multi_az" {
  description = "value of the database multi az"
  default     = true
}

variable "db_engine" {
  description = "The type of database engine"
  default     = "postgres"
}

variable "db_engine_version" {
  description = "The version of the database engine"
  default     = "16"
}

variable "db_major_engine_version" {
  description = "The major version of the database engine"
  default     = "16"
}

variable "db_instance_class" {
  description = "The instance class for the database"
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "The amount of storage to allocate for the database"
  default     = 5
}

variable "db_max_allocated_storage" {
  description = "The maximum amount of storage to allocate for the database"
  default     = 10
}

variable "db_subnet_group_name" {
  description = "The name of the database subnet group"
}

variable "db_security_group_ids" {
  description = "The IDs of the security groups for the database"
  type        = list(string)
}

variable "db_maintenance_window" {
  description = "The maintenance window for the database"
  default     = "Mon:00:00-Mon:03:00"
}

variable "db_backup_window" {
  description = "The backup window for the database"
  default     = "03:00-06:00"
}

variable "db_backup_retaintion_period" {
  description = "The backup retention period for the database"
  default     = 1
}

variable "db_skip_final_snapshot" {
  description = "Whether to skip the final snapshot for the database"
  default     = true
}

variable "db_deletion_protection" {
  description = "Whether to enable deletion protection for the database"
  default     = false
}

variable "db_parameters" {
  description = "values of the database parameters"
  type = list(object({
    name  = string
    value = string
  }))
  default = [{
    name  = "autovacuum"
    value = "1"
    }, {
    name  = "client_encoding"
    value = "utf8"
    }, {
    name  = "rds.force_ssl"
    value = "0"
  }]
}
