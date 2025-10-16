output "steep_token" {
  value     = snowflake_user_programmatic_access_token.steep_access_token.token
  sensitive = true
}
