module "apigateway" {
  source       = "../../../terraform/modules/apigateway"
  api_name     = "test-apigateway"
  backend_url  = "https://dummy-backend.example.com"
  frontend_url = "https://dummy-frontend.example.com"
  environment  = "dev"
  common_tags  = {
    Environment = "test"
    Module      = "apigateway-test"
  }
}

output "api_endpoint" {
  value = module.apigateway.api_endpoint
} 