variable "compartment_ocid" {
  description = "OCID del compartimento"
}

variable "oci_core_instance_source_id" {
  description = "OCID de la imagen fuente"
}

variable "availability_domain" {
  description = "Dominio de disponibilidad"
}

variable "fault_domain" {
  description = "Dominio de fallos"
}

variable "region" {
  description = "Región de OCI"
}

variable "tenancy_ocid" {
  description = "OCID del tenancy"
}

variable "ssh_public_key" {
  description = "Clave pública SSH"
}

variable "user_ocid" {
  description = "OCID del usuario"
}

variable "fingerprint" {
  description = "Huella digital del API key"
}

variable "ssh_private_key" {
  description = "Ruta a la clave privada SSH"
}

variable "vcn_id" {
  description = "OCID del VCN"
}
