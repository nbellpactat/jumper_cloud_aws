resource "aws_vpc" "spinnaker" {
  cidr_block = var.spinnaker_vpc_cidr
}

resource "aws_route_table" "base" {
  vpc_id = aws_vpc.spinnaker.id
}

resource "aws_route_table" "spinnaker_private" {
  vpc_id = aws_vpc.spinnaker.id
}

resource "aws_route" "local" {
  route_table_id            = aws_route_table.spinnaker_private.id
  destination_cidr_block    = aws_vpc.spinnaker.cidr_block
  depends_on                = [aws_route_table.spinnaker_private, aws_vpc.spinnaker]
}

resource "aws_network_acl" "base" {
  vpc_id = aws_vpc.spinnaker.id
}

resource "aws_subnet" "spinnaker_private" {
  vpc_id     = aws_vpc.spinnaker.id
  cidr_block = var.spinnaker_subnet_private_cidr
}
