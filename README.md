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
