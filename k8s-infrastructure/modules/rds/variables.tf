variable "postgres" {
  default = {
    instance_name         = "dx-ckan-db"
    family                = "postgres11"
    instance_class        = "db.m5.large"
    instance_version      = "11.19"
    database_name         = "ckan"
    database_user_name    = "postgres"
    allocated_storage     = "100"
    max_allocated_storage = "150"
    backup_retention      = 7
    maintenance_window    = "Mon:00:00-Mon:03:00"
    backup_window         = "03:00-06:00"
  }

  type = object({
    instance_name         = string
    family                = string
    instance_class        = string
    database_name         = string
    instance_version      = string
    database_user_name    = string
    allocated_storage     = string
    max_allocated_storage = string
    maintenance_window    = string
    backup_window         = string
    backup_retention      = number
  })

}
variable "db_subnet_group" {}
variable "security_group_rds_id" {}