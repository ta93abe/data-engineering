resource "snowflake_database" "production_database" {
  name                           = "PRODUCTION_DB"
  drop_public_schema_on_creation = true
}
