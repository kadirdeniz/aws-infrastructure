resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge({
    Name        = "${var.environment}-vpc"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
  }, var.tags)
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge({
    Name        = "${var.environment}-public-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
    Type        = "public"
  }, var.tags)
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.azs[count.index]
  tags = merge({
    Name        = "${var.environment}-private-${count.index + 1}"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
    Type        = "private"
  }, var.tags)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name        = "${var.environment}-igw"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
  }, var.tags)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
    Type        = "public"
  }, var.tags)
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name        = "${var.environment}-private-rt"
    Environment = var.environment
    Project     = var.project
    Owner       = var.owner
    ManagedBy   = "terraform"
    Type        = "private"
  }, var.tags)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
} 