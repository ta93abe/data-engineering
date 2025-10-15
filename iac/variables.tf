variable "snowflake_organization_name" {
  description = "Snowflake account identifier"
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_private_key" {
  description = "Private key for Snowflake authentication (PEM format without encryption)"
  type        = string
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role to use"
  type        = string
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse to use"
  type        = string
}
