terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

resource "aws_apigatewayv2_api" "this" {
  name          = var.api_name
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*", "Authorization", "Content-Type"]
    max_age       = 86400
  }
}

resource "aws_apigatewayv2_integration" "backend" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri  = var.backend_url
}

resource "aws_apigatewayv2_integration" "frontend" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri  = var.frontend_url
}

resource "aws_apigatewayv2_route" "api_backend" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /api/{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
}

resource "aws_apigatewayv2_route" "frontend" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.frontend.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
}

# HTTPS enforcement is default for HTTP APIs, but you can add usage plan/rate limiting via API Gateway usage plan if needed.
# IAM roles and policies for API Gateway access can be added as needed. 