# マネージドディスクの情報
data "azurerm_managed_disk" "testvm_disk" {
  name = "testwin_OsDisk_1_6dd450af616046a58796240a3dac04c3"
  resource_group_name = "resourcegroup"
}

# ネットワークセキュリティグループの作成
resource "azurerm_network_security_group" "testvmnsg" {
  name                = "test-vm-01-nsg"
  location            = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
  security_rule {
    name                       = "rule-01"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefixes    = ["192.168.1.1"]
    destination_address_prefix = "VirtualNetwork"
  }
  tags = {}
}


# ネットワークインターフェースの作成
resource "azurerm_network_interface" "testvmnic" {
  name = "testvm-nic"
  location = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
  
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.test_subnet.id}"
    private_ip_address_allocation = "Static"  # Static：固定
    private_ip_address            = "10.0.0.20"
  }
}

# ネットワークインターフェースにNSGをアタッチ
resource "azurerm_network_interface_security_group_association" "test-vm-nic-nsg-01" {
  network_interface_id = azurerm_network_interface.testvmnic.id
  network_security_group_id = azurerm_network_security_group.testvmnsg.id
}

# VMの作成
resource "azurerm_virtual_machine" "testvm" {
  name = "testwin_OsDisk_1_6dd450af616046a58796240a3dac04c3"
  location = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
  network_interface_ids = [ azurerm_network_interface.testvmnic.id ]

  # OSディスクの情報
  storage_os_disk {
    name = data.azurerm_managed_disk.testvm_disk.name
    caching = "ReadWrite"
    create_option = "Attach"
    managed_disk_id = data.azurerm_managed_disk.testvm_disk.id
    os_type = "Windows"
  }
  vm_size = "Standard_DS1_v2"

  os_profile_windows_config {
    enable_automatic_upgrades = true  # VM Agentの自動アップデート有効化
    provision_vm_agent = true  # VM Agentのインストール
  }

}