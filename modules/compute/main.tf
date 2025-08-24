# --- VPC and Availability Zones ---

# Fetches the available Availability Zones in the selected region
data "aws_availability_zones" "available" {
  state = "available"
}

# Creates the Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# --- Internet Gateway for Public Subnet ---

# Creates an Internet Gateway to allow communication with the internet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# --- Subnets ---

# Creates the public management subnet in the first AZ
resource "aws_subnet" "management" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.management_subnet_cidr
  availability_zone       = data.aws_availability_zones.available.names[0] # e.g., us-east-1a
  map_public_ip_on_launch = true                                           # Assigns public IPs automatically

  tags = {
    Name = "management-subnet"
  }
}

# Creates the private application subnet in the second AZ
resource "aws_subnet" "application" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.application_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1] # e.g., us-east-1b

  tags = {
    Name = "application-subnet"
  }
}

# Creates the private backend subnet in the first AZ
resource "aws_subnet" "backend" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.backend_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0] # e.g., us-east-1a

  tags = {
    Name = "backend-subnet"
  }
}

# --- Routing for Public Subnet ---

# Creates a route table for public traffic
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  # Route to the Internet Gateway for all outbound traffic (0.0.0.0/0)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associates the public route table with the management subnet
resource "aws_route_table_association" "management" {
  subnet_id      = aws_subnet.management.id
  route_table_id = aws_route_table.public.id
}

# --- Routing for Private Subnets ---

# Creates a route table for private traffic (no route to the internet)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt"
  }
}

# Associates the private route table with the application subnet
resource "aws_route_table_association" "application" {
  subnet_id      = aws_subnet.application.id
  route_table_id = aws_route_table.private.id
}

# Associates the private route table with the backend subnet
resource "aws_route_table_association" "backend" {
  subnet_id      = aws_subnet.backend.id
  route_table_id = aws_route_table.private.id
}
