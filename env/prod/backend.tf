resource "aws_s3_bucket" "tfm_state_bucket" {
  bucket = "wri-odp-tfm-state-bucket"
}

resource "aws_s3_bucket_versioning" "tfm_state_bucket_versioning" {
  bucket = aws_s3_bucket.tfm_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfm_state_bucket_encryption" {
  bucket = aws_s3_bucket.tfm_state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tfm_state_lock" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  name         = "tfm-state-lock"

  attribute {
    name = "LockID"
    type = "S"
  }
}