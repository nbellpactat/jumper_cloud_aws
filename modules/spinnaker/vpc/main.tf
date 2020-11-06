resource "aws_vpc" "spinnaker" {
  cidr_block = var.spinnaker_vpc_cidr
}

resource "aws_subnet" "spinnaker_private" {
  cidr_block = var.spinnaker_subnet_private_cidr
  vpc_id     = aws_vpc.spinnaker.id

  tags = {
    name = var.spinnaker_private_subnet_name
  }
}

resource "aws_subnet" "spinnaker_public" {
  cidr_block = var.spinnaker_subnet_public_cidr
  vpc_id     = aws_vpc.spinnaker.id

  tags = {
    name = var.spinnaker_public_subnet_name
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = aws_vpc.spinnaker.id
}

resource "aws_route_table" "base" {
  vpc_id = aws_vpc.spinnaker.id
}

resource "aws_nat_gateway" "spinnaker" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.spinnaker_public.id

  tags = {
    name = var.nat_gateway_name
  }
}

resource "aws_route_table" "spinnaker_private" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    name = var.spinnaker_private_route_table_name
  }
}

resource "aws_route" "local" {
  route_table_id         = aws_route_table.spinnaker_private.id
  destination_cidr_block = aws_vpc.spinnaker.cidr_block
  depends_on             = [aws_route_table.spinnaker_private, aws_vpc.spinnaker]
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.spinnaker_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.spinnaker.id
}

resource "aws_network_acl" "base" {
  vpc_id = aws_vpc.spinnaker.id
}
