output "vm_uuid" {
  description = "UUID of the created VM"
  value       = pilvio_vm.nextcloud.uuid
}

output "vm_public_ipv4" {
  description = "Public IPv4 address of the VM"
  value       = pilvio_vm.nextcloud.public_ipv4
}

output "assigned_floating_ip" {
  description = "Assigned floating IPv4 to the VM"
  value       = local.ip_address
}

output "vm_public_ipv6" {
  description = "Public IPv6 address of the VM"
  value       = pilvio_vm.nextcloud.public_ipv6
}

output "vm_private_ipv4" {
  description = "Private IPv4 address of the VM"
  value       = pilvio_vm.nextcloud.private_ipv4
}

output "created_bucket" {
  value = pilvio_bucket.s3_bucket
  sensitive = true
}

output "access_key" {
  value = local.parsed.s3Credentials[0].accessKey
  sensitive = true
}

output "secret_key" {
  value     = local.parsed.s3Credentials[0].secretKey
  sensitive = true
}