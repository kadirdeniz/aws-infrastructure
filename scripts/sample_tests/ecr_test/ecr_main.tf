# Test ECR Module
module "ecr" {
  source = "../../../terraform/modules/ecr"

  backend_repository_name  = "test-backend-repo"
  frontend_repository_name = "test-frontend-repo"
  environment             = "test"
  
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"
  max_image_count      = 5
  
  common_tags = {
    Project     = "test-project"
    Owner       = "test-user"
    Environment = "test"
    Test        = "true"
  }
} 