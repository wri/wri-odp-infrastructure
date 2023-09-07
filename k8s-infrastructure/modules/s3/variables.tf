
variable "storage" {
  type        = string
  description = "(required since we are not using 'bucket') Creates a unique bucket name beginning with the specified prefix"
  default     = "ckan-storage"
}

variable "cluster_name" { }
