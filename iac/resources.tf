locals {
  sysadmin_role = "SYSADMIN"
}

resource "snowflake_database" "production_database" {
  name                           = "PRODUCTION_DB"
  drop_public_schema_on_creation = true
}

resource "snowflake_database" "development_database" {
  name                           = "DEVELOPMENT_DB"
  drop_public_schema_on_creation = true
}

resource "snowflake_schema" "raw_schema_in_production" {
  name     = "RAW"
  database = snowflake_database.production_database.name
  comment  = "Schema for raw data"
}

resource "snowflake_schema" "staging_schema_in_production" {
  name     = "STAGING"
  database = snowflake_database.production_database.name
  comment  = "Schema for staging data"
}

resource "snowflake_schema" "intermediate_schema_in_production" {
  name     = "INTERMEDIATE"
  database = snowflake_database.production_database.name
  comment  = "Schema for intermediate data"
}

resource "snowflake_schema" "marts_schema_in_production" {
  name     = "MARTS"
  database = snowflake_database.production_database.name
  comment  = "Schema for marts data"
}

resource "snowflake_account_role" "dbt_role" {
  name = "DBT_ROLE"
}

resource "snowflake_warehouse" "dbt_warehouse" {
  name                = "DBT_WH"
  warehouse_size      = "XSMALL"
  auto_resume         = true
  auto_suspend        = 60
  initially_suspended = true
}

resource "snowflake_service_user" "dbt_user" {
  name              = "DBT"
  login_name        = "DBT"
  rsa_public_key    = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAzmgpaMejMTheLtx+EY2LcFzrH2zjblheSjd0+GtpCsHFOagKB2CRcSAZM5+Mu/0iiOKHVyMP+1jDNyeU4OWWI8jkiogCA9rszK51fH6znD7te1DnzWk2GVPz24U9rW8UH1NlyMkjpJx+OIavtJk3bMRd30zSqTg+Qfbtl7QZHAMzx9Dzv1j5VztH5c4783qDaw8WX9MpjFgRW2NN3AmU8mLPqTbK+6JlBjfoVO4WLudQvpVuVb6ZIBBYCo3Mywq1rIzrP79xGqoyEN8THvDJnSO1j5gq7BqoNeLaJ0Di7M1z9Do34JLCm0LJCD7Y9vkZaPEl66jJOrWc6MZyj+/y8wIDAQAB"
  default_role      = snowflake_account_role.dbt_role.name
  default_warehouse = snowflake_warehouse.dbt_warehouse.name
}

resource "snowflake_grant_privileges_to_account_role" "grant_usage_on_warehouse" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["USAGE", "OPERATE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.dbt_warehouse.name
  }
}

resource "snowflake_grant_account_role" "grant_role_to_user" {
  role_name = snowflake_account_role.dbt_role.name
  user_name = snowflake_service_user.dbt_user.name
}

resource "snowflake_grant_privileges_to_account_role" "grant_usage_on_database" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.production_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_all_schemas" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE FUNCTION"]
  on_schema {
    all_schemas_in_database = snowflake_database.production_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_future_schemas" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE FUNCTION"]
  on_schema {
    future_schemas_in_database = snowflake_database.production_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_all_tables" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.production_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_future_tables" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.production_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_all_views" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["SELECT", "REFERENCES"]
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.production_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_future_views" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["SELECT", "REFERENCES"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.production_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_all_functions" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["USAGE"]
  on_schema_object {
    all {
      object_type_plural = "FUNCTIONS"
      in_database        = snowflake_database.production_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_all_on_future_functions" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["USAGE"]
  on_schema_object {
    future {
      object_type_plural = "FUNCTIONS"
      in_database        = snowflake_database.production_database.name
    }
  }
}

# SYSADMIN grants for DEVELOPMENT_DB
resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_usage_on_development_database" {
  account_role_name = local.sysadmin_role
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.development_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_all_schemas_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE FUNCTION"]
  on_schema {
    all_schemas_in_database = snowflake_database.development_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_future_schemas_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE FUNCTION"]
  on_schema {
    future_schemas_in_database = snowflake_database.development_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_all_tables_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.development_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_future_tables_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_database        = snowflake_database.development_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_all_views_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["SELECT", "REFERENCES"]
  on_schema_object {
    all {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.development_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_future_views_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["SELECT", "REFERENCES"]
  on_schema_object {
    future {
      object_type_plural = "VIEWS"
      in_database        = snowflake_database.development_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_all_functions_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["USAGE"]
  on_schema_object {
    all {
      object_type_plural = "FUNCTIONS"
      in_database        = snowflake_database.development_database.name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_sysadmin_all_on_future_functions_dev" {
  account_role_name = local.sysadmin_role
  privileges        = ["USAGE"]
  on_schema_object {
    future {
      object_type_plural = "FUNCTIONS"
      in_database        = snowflake_database.development_database.name
    }
  }
}


