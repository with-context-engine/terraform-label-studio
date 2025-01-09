resource "aws_ecr_repository" "label_studio_image_repository" {
  name = "${var.identifier}-label-studio-image-repository"
}
