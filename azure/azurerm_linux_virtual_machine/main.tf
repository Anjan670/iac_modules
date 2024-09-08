resource "azurerm_public_ip" "public_ip" {
  for_each            = var.public_ip
  name                = each.value["name"]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = each.value["allocation_method"]
}
resource "azurerm_network_interface" "nic" {
  for_each            = var.linux_virtualmachine
  name                = "${each.value["name"]}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dynamic "ip_configuration" {
    for_each = var.linux_virtualmachine.network_interface
    content {
      name                          = "internal"
      subnet_id                     = data.azurerm_subnet.snet.id
      public_ip_address_id          = var.public_ip == null ? null : azurerm_public_ip.public_ip.id
      private_ip_address_allocation = "Static"
      private_ip_address            = ip_configuration.value["private_ip_address"]
      private_ip_address_version    = "IPv4"
    }

  }
}
resource "azurerm_linux_virtual_machine" "lin_vm" {
  for_each            = var.linux_virtualmachine
  name                = each.value["name"]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = each.value["size"]
  admin_username      = each.value["admin_username"]
  admin_password      = each.value["admin_password"]
  network_interface_ids = [
    [for nc in azurermazurerm_network_interface.nic : nc.id],
  ]
  dynamic "source_image_reference" {
    for_each = var.linux_virtualmachine.source_image_reference
    content {
      publisher = source_image_reference.value["publisher"]
      offer     = source_image_reference.value["offer"]
      sku       = source_image_reference.value["sku"]
      version   = source_image_reference.value["version"]
    }
  }
  dynamic "os_disk" {
    for_each = var.linux_virtualmachine.os_disk
    content {
      caching              = os_disk.value["caching"]
      storage_account_type = os_disk.value["storage_account_type"]
    }
  }

}
resource "azurerm_managed_disk" "data_disk" {
  for_each             = var.common_windowsVM.data_disk
  name                 = each.value["name"]
  location             = data.azurerm_resource_group.rg.location
  resource_group_name  = data.azurerm_resource_group.rg.name
  storage_account_type = each.value["storage_account_type"]
  create_option        = "Empty"
  disk_size_gb         = each.value["disk_size_gb"]
}
resource "azurerm_virtual_machine_data_disk_attachment" "diskattachment" {
  managed_disk_id    = [for disk in azurermazurerm_managed_disk.data_disk : disk.id]
  virtual_machine_id = [for vm in azurerm_linux_virtual_machine.lin_vm : vm.id]
  lun                = var.common_windowsVM.data_disk.lun
  caching            = "ReadWrite"
}

