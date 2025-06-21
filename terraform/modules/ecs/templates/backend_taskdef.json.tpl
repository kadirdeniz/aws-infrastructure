[
  {
    "name": "${container_name}",
    "image": "${image}",
    "cpu": ${cpu},
    "memory": ${memory},
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080,
        "protocol": "tcp"
      }
    ],
    "environment": [
      {
        "name": "ENVIRONMENT",
        "value": "${environment}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
] 