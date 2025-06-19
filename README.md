# Label Studio on AppRunner Terraform Module

This Terraform module deploys Label Studio on AWS AppRunner. It simplifies the process of setting up Label Studio, a data labeling tool, by automating the infrastructure provisioning on AWS. The module handles the creation of necessary resources such as AppRunner services, VPC connectors, and database configurations, ensuring a seamless deployment experience.

## Usage

```hcl
module "label-studio-on-apprunner" {
  source  = "tied-inc/label-studio-on-apprunner/aws"

  apprunner_label_studio_ecr_image_identifier     = "annotation_image_identifier"
  apprunner_vpc_connector_security_group_ids      = ["sg-0123456789abcdef0"]
  apprunner_label_studio_ecr_image_repository_arn = "arn:aws:ecr:region:account-id:repository/repository-name"
  db_security_group_ids                           = ["sg-0123456789abcdef0"]
  db_subnet_group_name                            = "db-subnet-group"
  subnet_ids                                      = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
}
```


## Module Documentation

For detailed documentation on the module, including input and output variables, examples, and more, please refer to [Doc.md](./Doc.md).

## Contribution

Contributions are welcome! If you have any improvements or fixes, please submit a pull request. For major changes, please open an issue first to discuss what you would like to change. Make sure to follow the project's coding guidelines and standards.

## Commands 

You run these commands in the order they are listed to get the `terraform.tfvars` file following `terraform init` and before `terraform apply`. 

> [!WARNING]
> I have removed identifying information from the commands. Please use this as a guide to create your own commands. 

> [!WARNING]
> Do not build the image on your Mac. It will not work. You need to build the image on a Linux machine such as a EC2 instance. 

| Step | Command | Output | Variable | Description / Notes |
|------|---------|--------|----------|---------------------|
| 1 | `aws ecr get-login-password --region us-east-1 \| docker login --username AWS --password-stdin your-aws-account-id.dkr.ecr.us-east-1.amazonaws.com` | Docker login success message | – | Authenticate Docker to ECR |
| 2 | `docker pull heartexlabs/label-studio` | Pulls Label Studio image | – | Get the latest Label Studio image |
| 3 | `docker tag heartexlabs/label-studio:latest your-aws-account-id.dkr.ecr.us-east-1.amazonaws.com/with-context/labelstudio:latest` | – | – | Tag the image for your ECR repo |
| 4 | `docker push your-aws-account-id.dkr.ecr.us-east-1.amazonaws.com/with-context/labelstudio:latest` | Push success message | – | Push the image to your ECR repo |
| 5 | `aws ecr describe-repositories --query 'repositories[].repositoryArn' --output json \| jq` | List of repository ARNs | apprunner_label_studio_ecr_image_repository_arn | Capture the ECR repository ARN (Variable 1 of 6) |
| 6 | `aws ecr describe-repositories --query 'repositories[].repositoryUri' --output json \| jq` | List of repository URIs | apprunner_label_studio_ecr_image_identifier | Capture the ECR repository URI (Variable 2 of 6) |
| 7 | `aws ec2 describe-vpcs --query "Vpcs[*].{VpcId:VpcId,Name:Tags[?Key=='Name']\|[0].Value}" --output table` | Table of VPC IDs and Names | – | Get your VPC IDs |
| 8 | `aws ec2 create-security-group --group-name your-application --description "Security Group for App Runner LabelStudio" --vpc-id vpc-xxxxxxxxxxxxxxxxx` | JSON with GroupId and SecurityGroupArn | apprunner_vpc_connector_security_group_ids, db_security_group_ids | Create a new security group (Variables 3 & 4 of 6) |
| 9 | `aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxxxxxxxxxxxxxx" --query "Subnets[*].SubnetId" --output text` | List of Subnet IDs | subnet_ids | List subnets for the VPC (Variable 5 of 6) be sure to only grab private subnets |
| 10 | `aws rds create-db-subnet-group --db-subnet-group-name your-group-name --db-subnet-group-description "Description" --subnet-ids subnet-x subnet-y subnet-z subnet-a` | Confirmation JSON | db_subnet_group_name | Create RDS subnet group (Variable 6 of 6) |
| 11 | `aws ec2 authorize-security-group-ingress --group-id your-db-sg-id --protocol tcp --port 5432 --source-group your-app-runner-sg-id` | Confirmation JSON | db_security_group_ids, apprunner_vpc_connector_security_group_ids | Allow App Runner traffic to the RDS instance on port 5432. Note that this will be added to the `db_security_group_ids` variable and then be depreciated. |


## Connect to the RDS instance

From an EC2 instance, you can connect to the RDS instance. You can follow the tutorial [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_GettingStarted.CreatingConnecting.PostgreSQL.html#CHAP_GettingStarted.Connecting.PostgreSQL). Within your EC2 instance, you can run the following command to connect to the RDS instance:

```bash
psql -h your-rds-endpoint -p 5432 -U your-db-username -d your-db-name
```

You can find the RDS endpoint, username, and database name in the AppRunner configuration and in the `variables.tf` file.