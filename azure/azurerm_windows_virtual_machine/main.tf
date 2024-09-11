resource "azurerm_public_ip" "public_ip" {
  for_each            = var.public_ip
  name                = each.value["name"]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  allocation_method   = each.value["allocation_method"]
}
resource "azurerm_network_interface" "nic" {
  for_each = { for config in var.config : config.network_interface_name => config }

  name                = each.value.network_interface_name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.example[each.value.resource_group_name].name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example[each.value.subnet_name].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "win_vm" {
  for_each = { for config in var.config : config.vm_name => config }

  name                = each.value.vm_name
  resource_group_name = azurerm_resource_group.example[each.value.resource_group_name].name
  location            = each.value.location
  size                = each.value.vm_size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic[each.value.network_interface_name].id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = each.value.os_disk_size_gb
  }
  tags = each.value.tags
}

resource "azurerm_managed_disk" "data_disk" {
  for_each             = { for config in var.config : config.data_disk_name => config }
  name                 = each.value.data_disk_name
  resource_group_name  = azurerm_resource_group.example[each.value.resource_group_name].name
  location             = each.value.location
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = each.value.data_disk_size_gb
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk_attachment" {
  for_each = { for config in var.config : config.vm_name => config }
  virtual_machine_id = azurerm_windows_virtual_machine.example[each.key].id
  managed_disk_id    = azurerm_managed_disk.data_disk[each.value.data_disk_name].id
  lun                = 0
  caching            = "ReadWrite"
  create_option      = "Attach"
}
