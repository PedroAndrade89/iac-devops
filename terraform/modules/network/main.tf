data "aws_availability_zones" "available" {}


############################################################################################################
### VPC
############################################################################################################
resource "aws_vpc" "main" {

  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    var.default_tags,
    {
      Name = var.vpc_name
    }
  )
}

resource "aws_default_security_group" "main" {
  vpc_id = aws_vpc.main.id
}

############################################################################################################
### SUBNETS
############################################################################################################
## Public subnets
resource "aws_subnet" "public" {
  for_each = { for s in var.public_subnets : s.name => s }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.default_tags, var.public_subnet_tags,   # Add a comma here to separate the arguments
    {
      "Name" = "${var.vpc_name}-${each.value.name}"
    }
  )
}

## Private Subnets
resource "aws_subnet" "private" {
  for_each = { for s in var.private_subnets : s.name => s }

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.default_tags, var.private_subnet_tags,  # Add a comma here to separate the arguments
    {
      "Name" = "${var.vpc_name}-${each.value.name}"
    }
  )
}




############################################################################################################
### INTERNET GATEWAY
############################################################################################################
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.default_tags, {
      Name = "${var.vpc_name}-internetgateway"
    })
}


############################################################################################################
### NAT GATEWAY
############################################################################################################

resource "aws_eip" "nat_gateway" {
  count = var.nat_gateway ? 1 : 0

  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  count = var.nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat_gateway[0].id
  subnet_id     = aws_subnet.public[sort(keys(aws_subnet.public))[0]].id

  tags = merge(
    var.default_tags, {
      Name = "${var.vpc_name}-natgateway-default"
    })

  depends_on = [
    aws_internet_gateway.main
  ]
}


############################################################################################################
### ROUTE TABLES
############################################################################################################
# Public Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.default_tags, {
      Name = "${var.vpc_name}-routetable-public"
    })
}

## Public Route Table rules
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

## Public Route table associations
resource "aws_route_table_association" "public-associations" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.default_tags, {
      Name = "${var.vpc_name}-routetable-private"
    })
}

## Private Route Table rules
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = var.nat_gateway ? aws_nat_gateway.main[0].id : null
  destination_cidr_block = "0.0.0.0/0"
}

## Private Route table associations
resource "aws_route_table_association" "private-associations" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}