variable "vnet_name" {
  description = "The name of the virtual network."
  default     = "tf-vnet"
}

variable "vnet_address_space" {
  description = "vNet address space"
  default     = ["10.1.0.0/24"]
}

variable "subnet" {
  description = "subnet address space"
  default     = "10.1.0.0/24"
}

variable "vmname" {
  description = "VM name"
  default     = "node2"
}

variable "username" {
  description = "VM user name"
  default     = "deployer"
}

variable "password" {
  description = "VM user password"
  default     = "demopass@123"
}

variable "lbport" {
  description = "LB Backend Port"
  default     = 32768
}
