output "spinnaker_vpc_id" {
  value = aws_vpc.spinnaker.id
}

output "spinnaker_vpc_cidr" {
  value = aws_vpc.spinnaker.cidr_block
}

output "spinnaker_private_subnet_id" {
  value = aws_subnet.spinnaker_private.id
}

output "spinnaker_security_group_id" {
  value = aws_security_group.spinnaker.id
}