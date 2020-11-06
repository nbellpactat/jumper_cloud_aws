output "spinnaker_vpc_id" {
  value = aws_vpc.spinnaker.id
}

output "spinnaker_vpc_cidr" {
  value = aws_vpc.spinnaker.cidr_block
}