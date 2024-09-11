variable "common_windowsVM" {
  description = "value"
  type = object({
    resource_group_name  = string
    virtual_network_name = string
    subnet_name          = string
  })
}
variable "public_ip" {
  description = "value"
  type = object({
    name              = string
    allocation_method = string
  })
}
variable "config" {
  description = "List of configurations for the Windows VMs and associated resources."
  type = list(object({
    resource_group_name    = string
    location               = string
    virtual_network_name   = string
    address_space          = string
    subnet_name            = string
    subnet_address_prefix  = string
    network_interface_name = string
    vm_name                = string
    vm_size                = string
    admin_username         = string
    admin_password         = string
    os_disk_size_gb        = number
    data_disk_name         = string
    data_disk_size_gb      = number
    tags                   = map(string)
  }))
}

