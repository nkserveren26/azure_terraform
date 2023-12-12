# マネージドディスクの情報
data "azurerm_managed_disk" "testvm_disk" {
  name = "testvm-disk"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
}

# ネットワークインターフェースの作成
resource "azurerm_network_interface" "testvmnic" {
  name = "testvm-nic"
  location = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.test_subnet.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.20"
  }
}

# VMの作成
resource "azurerm_virtual_machine" "testvm" {
  name = "testvm"
  location = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.location}"
  network_interface_ids = [ azurerm_network_interface.testvmnic.id ]
  storage_os_disk {
    name = "testvm-os-disk"
    managed_disk_type = "Standard_LRS"
    create_option = "Attach"
    managed_disk_id = data.azurerm_managed_disk.testvm_disk.id
  }
  vm_size = "Standard_DS1_v2"
  os_profile {
    computer_name = "my-test-vm"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

}