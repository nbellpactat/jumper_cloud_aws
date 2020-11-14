output "spinnaker_vpc_id" {
  value = module.spinnaker_vpc_resources.spinnaker_vpc_id
}

output "spinnaker_private_subnet_id" {
  value = module.spinnaker_vpc_resources.spinnaker_private_subnet_id
}