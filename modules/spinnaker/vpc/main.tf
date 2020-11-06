resource "aws_vpc" "spinnaker" {
  cidr_block = var.spinnaker_vpc_cidr

  tags = {
    name = var.spinnaker_vpc_name
  }
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

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    name = var.internet_gateway_name
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true

  tags = {
    name = var.nat_eip_name
  }
}

resource "aws_route_table" "base" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    name = "spinnaker_base_route_table"
  }
}

resource "aws_nat_gateway" "spinnaker" {
  depends_on = [aws_internet_gateway.internet_gateway]

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

resource "aws_route" "nat" {
  depends_on = [aws_nat_gateway.spinnaker]

  route_table_id         = aws_route_table.spinnaker_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.spinnaker.id
}

resource "aws_network_acl" "base" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    name = "spinnaker_base_nacl"
  }
}
