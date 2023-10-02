
/* Create the bucket  */
resource "aws_s3_bucket" "ckan_storage" {
  bucket = "${var.cluster_name}-${var.storage}"
}

resource "aws_s3_bucket_public_access_block" "ckan_storage_acl" {
  bucket                  = aws_s3_bucket.ckan_storage.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

