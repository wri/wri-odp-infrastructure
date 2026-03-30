resource "aws_dynamodb_table" "tfm_state_lock" {
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  name         = "tfm-state-lock"

  attribute {
    name = "LockID"
    type = "S"
  }
}