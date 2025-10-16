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

resource "snowflake_schema" "raw_schema_in_development" {
  name     = "RAW"
  database = snowflake_database.development_database.name
  comment  = "Schema for raw data"
}

resource "snowflake_schema" "staging_schema_in_development" {
  name     = "STAGING"
  database = snowflake_database.development_database.name
  comment  = "Schema for staging data"
}

resource "snowflake_schema" "intermediate_schema_in_development" {
  name     = "INTERMEDIATE"
  database = snowflake_database.development_database.name
  comment  = "Schema for intermediate data"
}

resource "snowflake_schema" "marts_schema_in_development" {
  name     = "MARTS"
  database = snowflake_database.development_database.name
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

resource "snowflake_user" "dbt_user" {
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
  user_name = snowflake_user.dbt_user.name
}

resource "snowflake_grant_account_role" "grant_dbt_role_to_sysadmin" {
  role_name        = snowflake_account_role.dbt_role.name
  parent_role_name = local.sysadmin_role
}

resource "snowflake_grant_privileges_to_account_role" "grant_usage_on_database" {
  account_role_name = snowflake_account_role.dbt_role.name
  privileges        = ["USAGE", "CREATE SCHEMA"]
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
  privileges        = ["USAGE", "CREATE SCHEMA"]
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

resource "snowflake_warehouse" "steep_warehouse" {
  name           = "STEEP_WH"
  warehouse_size = "XSMALL"
}

resource "snowflake_account_role" "steep_role" {
  name = "STEEP_ROLE"
}

resource "snowflake_user" "steep_user" {
  name              = "STEEP"
  login_name        = "STEEP"
  default_role      = snowflake_account_role.steep_role.name
  default_warehouse = snowflake_warehouse.steep_warehouse.name
  network_policy    = snowflake_network_policy.allow_steep_connection.name
}

resource "snowflake_grant_account_role" "grant_steep_role_to_sysadmin" {
  role_name        = snowflake_account_role.steep_role.name
  parent_role_name = local.sysadmin_role
}

resource "snowflake_user_programmatic_access_token" "steep_access_token" {
  user = snowflake_user.steep_user.name
  name = "STEEP_TOKEN"
}

resource "snowflake_network_rule" "enable_incoming_from_steep" {
  name       = "ENABLE_INCOMING_FROM_STEEP"
  mode       = "INGRESS"
  type       = "IPV4"
  value_list = ["34.78.69.173/32"]
  database   = snowflake_database.production_database.name
  schema     = snowflake_schema.marts_schema_in_production.name
}

resource "snowflake_network_policy" "allow_steep_connection" {
  name                      = "ALLOW_STEEP_CONNECTION"
  comment                   = "Allow incoming connections from Steep"
  allowed_network_rule_list = [snowflake_network_rule.enable_incoming_from_steep.fully_qualified_name]
}

resource "snowflake_warehouse" "evidence_warehouse" {
  name           = "EVIDENCE_WH"
  warehouse_size = "XSMALL"
}

resource "snowflake_account_role" "evidence_role" {
  name = "EVIDENCE_ROLE"
}

resource "snowflake_user" "evidence_user" {
  name              = "EVIDENCE"
  login_name        = "EVIDENCE"
  default_role      = snowflake_account_role.evidence_role.name
  default_warehouse = snowflake_warehouse.evidence_warehouse.name
  rsa_public_key    = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4wDibJhD0RhVNY7gSJecoB6W3zwzDQ+neWPfdMb6jTk+noczv8JiYsc47khQ1E1t74w28uWKvEwcnDv4cS5gVUuH5U+jozp7JZrf89tAeRMoevw5Luae6vWNOBK0qpAM51BU0/wgxq19ZbebFsmlmk8eswKKlJzTWMhQD7gFKNj3sw9Ces5IV0ESfnqkmoKck6Cy199WJA6NWE+LSCx1NXlNTVkIUyBvgLuRQJl9JwQ9wnrG5P3rvWl6ENWxlGEjx5TTzMWZE6NrJzsD9Z4WIAZUf1fu6mlXNlOQI3rZNIWY693wBlD/soPKVjD1bxOZbpNaag+JHB4/U99YROgwrwIDAQAB"
}

resource "snowflake_grant_account_role" "grant_evidence_role_to_user" {
  role_name = snowflake_account_role.evidence_role.name
  user_name = snowflake_user.evidence_user.name
}

resource "snowflake_grant_account_role" "grant_evidence_role_to_sysadmin" {
  role_name        = snowflake_account_role.evidence_role.name
  parent_role_name = local.sysadmin_role
}

resource "snowflake_grant_privileges_to_account_role" "grant_evidence_usage_on_warehouse" {
  account_role_name = snowflake_account_role.evidence_role.name
  privileges        = ["USAGE", "OPERATE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.evidence_warehouse.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_evidence_usage_on_production_database" {
  account_role_name = snowflake_account_role.evidence_role.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.production_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_evidence_usage_on_marts_schema" {
  account_role_name = snowflake_account_role.evidence_role.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = snowflake_schema.marts_schema_in_production.fully_qualified_name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_evidence_select_on_all_tables_in_marts" {
  account_role_name = snowflake_account_role.evidence_role.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.marts_schema_in_production.fully_qualified_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_evidence_select_on_future_tables_in_marts" {
  account_role_name = snowflake_account_role.evidence_role.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.marts_schema_in_production.fully_qualified_name
    }
  }
}

resource "snowflake_warehouse" "count_warehouse" {
  name           = "COUNT_WH"
  warehouse_size = "XSMALL"
}

resource "snowflake_account_role" "count_role" {
  name = "COUNT_ROLE"
}

resource "snowflake_user" "count_user" {
  name              = "COUNT"
  login_name        = "COUNT"
  default_role      = snowflake_account_role.count_role.name
  default_warehouse = snowflake_warehouse.count_warehouse.name
  rsa_public_key    = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoRy6f/KJRARP4ENEp72XlMXpTYcKp67/QyHO6wd8IXY7N9b74/srPhCO5JELRA5Rw+NWkQv5PZyLlrr8dB0KLvwQQ8qI1YNFNcPzRA/+QeS1yZ7Femi60/HT2I6NKNLDB47uaDxpTUHnbu3Vu0JSDMoBdK3EtDHvspkbPVsGVpZ/j+kxvlHfgMuT3yMLdpM9Qb1VPFWdCtc7F2/vS/twbAeOOwydwp6IHG8hHwp9hVxKl1fPDeP5NU49r/g7/l9NiRlYx0gbHE08v5e2qkjdJNwZDK1FFd/Vy5TqZFsxh454J3PbQYi5z/7ifANsZcR5NgIOlCRYZO40aba97uiQywIDAQAB"
}

resource "snowflake_grant_account_role" "grant_count_role_to_user" {
  role_name = snowflake_account_role.count_role.name
  user_name = snowflake_user.count_user.name
}

resource "snowflake_grant_account_role" "grant_count_role_to_sysadmin" {
  role_name        = snowflake_account_role.count_role.name
  parent_role_name = local.sysadmin_role
}

resource "snowflake_grant_privileges_to_account_role" "grant_count_usage_on_warehouse" {
  account_role_name = snowflake_account_role.count_role.name
  privileges        = ["USAGE", "OPERATE"]
  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.count_warehouse.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_count_usage_on_production_database" {
  account_role_name = snowflake_account_role.count_role.name
  privileges        = ["USAGE"]
  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.production_database.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_count_usage_on_marts_schema" {
  account_role_name = snowflake_account_role.count_role.name
  privileges        = ["USAGE"]
  on_schema {
    schema_name = "\"${snowflake_database.production_database.name}\".\"${snowflake_schema.marts_schema_in_production.name}\""
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_count_select_on_all_tables_in_marts" {
  account_role_name = snowflake_account_role.count_role.name
  privileges        = ["SELECT"]
  on_schema_object {
    all {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.marts_schema_in_production.fully_qualified_name
    }
  }
}

resource "snowflake_grant_privileges_to_account_role" "grant_count_select_on_future_tables_in_marts" {
  account_role_name = snowflake_account_role.count_role.name
  privileges        = ["SELECT"]
  on_schema_object {
    future {
      object_type_plural = "TABLES"
      in_schema          = snowflake_schema.marts_schema_in_production.fully_qualified_name
    }
  }
}

