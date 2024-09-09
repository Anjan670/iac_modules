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
variable "windows_virtualmachine" {
  description = "value"
  type = map(object({
    name           = string
    size           = string
    admin_username = string
    admin_password = string
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    os_disk = object({
      caching              = string
      storage_account_type = string
    })
    network_interface = object({
      private_ip_address         = string
      private_ip_address_version = string
    })
    data_disks = map(object({
      name                 = string
      storage_account_type = string
      disk_size_gb         = number
      lun                  = number
    }))
  }))
}
