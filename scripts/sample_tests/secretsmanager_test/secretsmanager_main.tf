module "secretsmanager" {
  source                   = "../../../terraform/modules/secretsmanager"
  secret_name              = "test-app-credentials"
  secret_description       = "Test application credentials"
  db_host                  = "test-db.example.com"
  db_port                  = 5432
  db_name                  = "testdb"
  db_username              = "testuser"
  create_api_keys_secret   = false
  recovery_window_in_days  = 0
  common_tags = {
    Environment = "test"
    Module      = "secretsmanager-test"
  }
}

output "secret_arn" {
  value = module.secretsmanager.secret_arn
} 