output "instance_public_ip" {
  value = oci_core_instance.instance.public_ip
}

output "instance_private_ip" {
  value = oci_core_instance.instance.private_ip
}
