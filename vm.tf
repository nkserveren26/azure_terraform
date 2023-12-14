# マネージドディスクの名前が入った配列変数
variable "disk_names" {
  default = [
    "testwin_OsDisk_1_6dd450af616046a58796240a3dac04c3", 
    "testvm2_OsDisk_1_5941274b12d14579b644c868c66610dd"
  ]
}

# マネージドディスクの情報
data "azurerm_managed_disk" "managed_disks" {
  count               = length(var.disk_names)
  name                = var.disk_names[count.index]
  resource_group_name = "resourcegroup"
}

# ネットワークセキュリティグループの作成
resource "azurerm_network_security_group" "testvmnsg" {
  count               = length(var.disk_names)
  name                = "${replace(var.disk_names[count.index], "-disk", "")}-nsg"
  location            = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
  security_rule {
    name                       = "DenyInternetAccessFromVM"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "Any"
    source_port_range          = "*"
    destination_port_ranges    = ["0-65535"]
    source_address_prefixes    = ["*"]
    destination_address_prefix = "Internet"
  }
  tags = {}
}


# ネットワークインターフェースの作成
resource "azurerm_network_interface" "testvmnics" {
  count               = length(var.disk_names)
  name = "${replace(var.disk_names[count.index], "-disk", "")}-nic"
  location = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
  
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.test_subnet.id}"
    private_ip_address_allocation = "Static"  # Static：固定
    private_ip_address            = "10.0.0.${count.index + 10}"
  }
}

# ネットワークインターフェースにNSGをアタッチ
resource "azurerm_network_interface_security_group_association" "test-vm-nic-nsg-01" {
  count                          = length(var.disk_names)
  network_interface_id = azurerm_network_interface.testvmnics[count.index].id
  network_security_group_id = azurerm_network_security_group.testvmnsg[count.index].id
}

# VMの作成
resource "azurerm_virtual_machine" "testvm" {
  count               = length(var.disk_names)
  name = "${replace(var.disk_names[count.index], "-disk", "")}"
  location = "${azurerm_resource_group.testresourcegroup.location}"
  resource_group_name = "${azurerm_resource_group.testresourcegroup.name}"
  network_interface_ids = [ azurerm_network_interface.testvmnics[count.index].id ]

  # OSディスクの情報
  storage_os_disk {
    name = data.azurerm_managed_disk.managed_disks[count.index].name
    caching = "ReadWrite"
    create_option = "Attach"
    managed_disk_id = data.azurerm_managed_disk.managed_disks[count.index].id
    os_type = "Windows"
  }
  vm_size = "Standard_DS1_v2"

  os_profile_windows_config {
    enable_automatic_upgrades = true  # VM Agentの自動アップデート有効化
    provision_vm_agent = true  # VM Agentのインストール
  }

}