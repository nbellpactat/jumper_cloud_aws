resource "aws_vpc" "spinnaker" {
  cidr_block = var.spinnaker_vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.spinnaker_vpc_name
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "spinnaker_private" {
  cidr_block = var.spinnaker_subnet_private_cidr
  vpc_id     = aws_vpc.spinnaker.id
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = var.spinnaker_private_subnet_name
  }
}

resource "aws_subnet" "spinnaker_public" {
  cidr_block = var.spinnaker_subnet_public_cidr
  vpc_id     = aws_vpc.spinnaker.id
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = var.spinnaker_public_subnet_name
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true

  tags = {
    Name = var.nat_eip_name
  }
}

resource "aws_route_table" "base" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    Name = "spinnaker_base_route_table"
  }
}

resource "aws_nat_gateway" "spinnaker" {
  depends_on = [aws_internet_gateway.internet_gateway]

  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.spinnaker_public.id

  tags = {
    Name = var.nat_gateway_name
  }
}

resource "aws_route_table" "spinnaker_public" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    Name = var.spinnaker_public_route_table_name
  }
}

resource "aws_route_table" "spinnaker_private" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    Name = var.spinnaker_private_route_table_name
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.spinnaker_public.id
  subnet_id = aws_subnet.spinnaker_public.id
}

resource "aws_route_table_association" "private" {
  route_table_id = aws_route_table.spinnaker_private.id
  subnet_id = aws_subnet.spinnaker_private.id
}

resource "aws_route" "nat" {
  depends_on = [aws_nat_gateway.spinnaker]

  route_table_id         = aws_route_table.spinnaker_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.spinnaker.id
}

resource "aws_route" "igw" {
  depends_on = [aws_internet_gateway.internet_gateway]

  route_table_id = aws_route_table.spinnaker_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet_gateway.id
}

resource "aws_network_acl" "base" {
  vpc_id = aws_vpc.spinnaker.id

  tags = {
    Name = "spinnaker_base_nacl"
  }
}

resource "aws_security_group" "spinnaker" {
  name        = "spinnaker_sg"
  description = "Security Group for Spinnaker"
  vpc_id      = aws_vpc.spinnaker.id

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_security_group_rule" "https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.spinnaker.cidr_block]
  security_group_id = aws_security_group.spinnaker.id
}

resource "aws_vpc_endpoint" "ssm" {
  service_name = "com.amazonaws.us-east-2.ssm"
  vpc_id = aws_vpc.spinnaker.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.spinnaker.id, aws_vpc.spinnaker.default_security_group_id]
  subnet_ids = [aws_subnet.spinnaker_private.id, aws_subnet.spinnaker_public.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssmmessages" {
  service_name = "com.amazonaws.us-east-2.ssmmessages"
  vpc_id = aws_vpc.spinnaker.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.spinnaker.id, aws_vpc.spinnaker.default_security_group_id]
  subnet_ids = [aws_subnet.spinnaker_private.id, aws_subnet.spinnaker_public.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2messages" {
  service_name = "com.amazonaws.us-east-2.ec2messages"
  vpc_id = aws_vpc.spinnaker.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.spinnaker.id, aws_vpc.spinnaker.default_security_group_id]
  subnet_ids = [aws_subnet.spinnaker_private.id, aws_subnet.spinnaker_public.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "kms" {
  service_name = "com.amazonaws.us-east-2.kms"
  vpc_id = aws_vpc.spinnaker.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.spinnaker.id, aws_vpc.spinnaker.default_security_group_id]
  subnet_ids = [aws_subnet.spinnaker_private.id, aws_subnet.spinnaker_public.id]
  private_dns_enabled = true
}