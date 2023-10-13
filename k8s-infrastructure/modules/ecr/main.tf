resource "aws_ecr_repository" "default" {
  name                 = "${var.cluster_name}-ecr"
  image_tag_mutability = var.ecr.mutability
  image_scanning_configuration {
    scan_on_push = var.ecr.scan_on_push
  }
}

resource "aws_ecr_repository" "odp-ecr" {
  for_each = toset(var.ecr_repositories)
  name                 = each.value
  image_tag_mutability = var.ecr.mutability
  image_scanning_configuration {
    scan_on_push = var.ecr.scan_on_push
  }
}