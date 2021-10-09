
// VPC Create
resource "aws_vpc" "development" {
  cidr_block = var.vpc.vpc_cidr

  tags = merge({
    Name = "development"
  }, var.custom_tags)
}

// Subnets Creation
resource "aws_subnet" "private_1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.development.id
  cidr_block        = var.vpc.subnet_private_1

  tags = merge({
    Name = "development-private-1"
  }, var.custom_tags)

}

resource "aws_subnet" "private_2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.development.id
  cidr_block        = var.vpc.subnet_private_2

  tags = merge({
    Name = "development-private-2"
  }, var.custom_tags)

}

resource "aws_subnet" "public_1" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.development.id
  cidr_block        = var.vpc.subnet_public_1

  tags = merge({
    Name = "development-public-1"
  }, var.custom_tags)

}

resource "aws_subnet" "public_2" {
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.development.id
  cidr_block        = var.vpc.subnet_public_2

  tags = merge({
    Name = "development-public-2"
  }, var.custom_tags)

}


// Internet Gateway
resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.development.id

  tags = merge({
    Name = "development"
  }, var.custom_tags)

}

// Route Tables Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.development.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }

  tags = merge({
    Name = "development-public"
  }, var.custom_tags)

}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}


// NAT Gateway
resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = merge({
    Name = "development"
  }, var.custom_tags)

}

// Route Tables Private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.development.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = merge({
    Name = "development-private"
  }, var.custom_tags)

}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}