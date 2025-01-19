provider oci {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid 
  private_key_path = var.ssh_private_key
  fingerprint = var.fingerprint
  region = var.region
}
