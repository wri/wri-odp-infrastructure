
/* Create the bucket  */
resource "aws_s3_bucket" "default" {
  bucket = "${var.cluster_name}-${var.storage}"
}

variable "acl" {
  type        = string
  description = "Defaults to private "
  default     = "private"
}
