variable "cluster_name" { }

variable "ecr" {
  default = {
    scan_on_push = false
    mutability   = "MUTABLE"
  }

  type = object({
    scan_on_push = bool
    mutability   = string
  })
}