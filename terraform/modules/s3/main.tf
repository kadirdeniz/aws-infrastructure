resource "aws_s3_bucket" "backend_bucket" {
  bucket = "${var.project}-${var.environment}-backend-storage"
  
  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-backend-storage"
    Type = "backend-storage"
  })
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "${var.project}-${var.environment}-frontend-storage"
  
  tags = merge(var.tags, {
    Name = "${var.project}-${var.environment}-frontend-storage"
    Type = "frontend-storage"
  })
}

# Backend bucket versioning
resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Frontend bucket versioning
resource "aws_s3_bucket_versioning" "frontend_versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Backend bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "backend_encryption" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Frontend bucket server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_encryption" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Backend bucket public access block
resource "aws_s3_bucket_public_access_block" "backend_public_access_block" {
  bucket = aws_s3_bucket.backend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Frontend bucket public access block
resource "aws_s3_bucket_public_access_block" "frontend_public_access_block" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Backend bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "backend_lifecycle" {
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    id     = "backup_retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# Frontend bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "frontend_lifecycle" {
  bucket = aws_s3_bucket.frontend_bucket.id

  rule {
    id     = "backup_retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

# IAM policy for backend bucket access
resource "aws_s3_bucket_policy" "backend_policy" {
  bucket = aws_s3_bucket.backend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.ecs_task_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.backend_bucket.arn,
          "${aws_s3_bucket.backend_bucket.arn}/*"
        ]
      }
    ]
  })
}

# IAM policy for frontend bucket access
resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.ecs_task_role_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.frontend_bucket.arn,
          "${aws_s3_bucket.frontend_bucket.arn}/*"
        ]
      }
    ]
  })
} 