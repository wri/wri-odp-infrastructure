resource "aws_s3_bucket" "ckan_storage" {
  for_each = toset(var.bucket_names)
  bucket   = each.value
}

resource "aws_s3_bucket_public_access_block" "ckan_storage_acl" {
  for_each = toset(var.bucket_names)
  bucket   = each.value
}