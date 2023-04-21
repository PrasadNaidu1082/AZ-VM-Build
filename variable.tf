variable "location" {
  description = "The location/region where the virtual network is created."
  default     = "South India"
}

variable "vm_hostname" {
  description = "local name of the VM"
  default     = "meine-pruefungVM"
}

variable "admin_username" {
  description = "The admin username of the VM that will be deployed"
  default     = "sysadmin"
}

variable "admin_password" {
  description = "The admin username of the VM that will be deployed"
  default     = "Sp@rrow007"
}
