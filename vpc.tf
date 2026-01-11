#VPC
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = merge(
    var.vpc_tags,
    local.comman_tags,

    {
        Name = local.comman_name_suffix
    }
  )
}

#Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.igw_tags,
    local.comman_tags,
    {
        Name = local.comman_name_suffix
    }
  )
}

#public subnet
resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs) #we're using loop function because we're creating two subnets and making them available for public
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true

    tags = merge(
    var.public_subnet_tags,
    local.comman_tags,
    {
        Name = "${local.comman_name_suffix}-public-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
    }
  )
}

# Private Subnet
resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs) #we're using loop function because we're creating two subnets and making them available for private
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]


    tags = merge(
     var.private_subnet_tags,
     local.comman_tags,
    {
        Name = "${local.comman_name_suffix}-private-${local.az_names[count.index]}" # roboshop-dev-private-us-east-1a
    }
  )
}

# database Subnet
resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs) #we're using loop function because we're creating two subnets and making them available for database
    vpc_id     = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]


    tags = merge(
     var.database_subnet_tags,
     local.comman_tags,
    {
        Name = "${local.comman_name_suffix}-database-${local.az_names[count.index]}" # roboshop-dev-database-us-east-1a
    }
  )
}

#public Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.public_route_table_tags,
    local.comman_tags,
    {
        Name = "${local.comman_name_suffix}-public"
    }
  )
}

# Private Route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_table_tags,
    local.comman_tags,
    {
        Name = "${local.comman_name_suffix}-private"
    }
  )
}

# Database Route table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route_table_tags,
    local.comman_tags,
    {
        Name = "${local.comman_name_suffix}-database"
    }
  )
}

#Public Route
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

# Elastic IP
resource "aws_eip" "nat" {
  domain   = "vpc"

  tags = merge(
     var.eip_tags, #elastic IP
     local.comman_tags,
    {
        Name = "${local.comman_name_suffix}-nat"
    }
  )
}

# NAT gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

   tags = merge(
     var.nat_gateway_tags, #elastic IP
     local.comman_tags,
    {
        Name = "${local.comman_name_suffix}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]
}

# Private Egress route through NAT
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# Database Egress route through NAT
resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
}

# public Assocation
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)  #as we've 2 Public IPs to associate we're calliing them via count function
  subnet_id      = aws_subnet.public[count.index].id 
  route_table_id = aws_route_table.public.id
}

# Private Assocation
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs) 
  subnet_id      = aws_subnet.private[count.index].id 
  route_table_id = aws_route_table.private.id
}

# Database Assocation
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)
  subnet_id      = aws_subnet.database[count.index].id 
  route_table_id = aws_route_table.database.id
}