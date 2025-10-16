terraform {
  required_providers {
    snowflake = {
      source = "snowflakedb/snowflake"
    }
  }
  cloud {
    organization = "ta93abe"
    hostname     = "app.terraform.io"
    workspaces {
      name = "data-engineering"
    }
  }
}

provider "snowflake" {
  organization_name        = var.snowflake_organization_name
  account_name             = var.snowflake_account_name
  user                     = var.snowflake_user
  role                     = var.snowflake_role
  authenticator            = "SNOWFLAKE_JWT"
  private_key              = var.snowflake_private_key
  warehouse                = var.snowflake_warehouse
  preview_features_enabled = ["snowflake_user_programmatic_access_token_resource"]
}
