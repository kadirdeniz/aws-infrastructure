output "api_endpoint" {
  description = "Invoke URL of the API Gateway."
  value       = aws_apigatewayv2_api.this.api_endpoint
}

output "api_id" {
  description = "ID of the API Gateway."
  value       = aws_apigatewayv2_api.this.id
}

output "stage_name" {
  description = "Name of the deployed stage."
  value       = aws_apigatewayv2_stage.default.name
} 