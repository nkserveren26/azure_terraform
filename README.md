# TerraformによるAzureリソース作成

## 環境構築
以下を実行環境にインストールする。

・Azure CLI
対象環境へのログインで必要。  
以下からインストーラーを取得し、インストールを実行。  
https://learn.microsoft.com/ja-jp/cli/azure/install-azure-cli-windows?tabs=azure-cli
　

・Terraform  
インストール手順
以下記事を参考にインストールを実行。  
　terraform.exeを配置したディレクトリパスをPATH環境変数に登録しておくと便利。  
https://blog.serverworks.co.jp/2021/10/25/164530

<br>

## tfファイルの作成
tfファイルを作成し、そこにAzureリソースを定義する。  
providerにazurermを指定する。  
```sample.tf
provider "azurerm" {
  features {}
  subscription_id = ""
  tenant_id = ""
}
```

resourceで各Azureリソースを定義する。  
```sample.tf
# リソースグループの作成
resource "azurerm_resource_group" "testresourcegroup" {
  name = "testresourcegroup"
  location = "Japan West"
}

# VNetの作成
resource "azurerm_virtual_network" "testvnet" {
  name = "testvnet"
  address_space = [ "10.0.0.0/16" ]
  location = azurerm_resource_group.testresourcegroup.location
  resource_group_name = azurerm_resource_group.testresourcegroup.name
}

# サブネットの作成
resource "azurerm_subnet" "test_subnet" {
  name = "testsubnet"
  resource_group_name = azurerm_resource_group.testresourcegroup.name
  virtual_network_name = azurerm_virtual_network.testvnet.name
  address_prefixes = [ "10.0.0.0/24" ]
}
```

<br>

## Terraform実行
初期化を実行。  
```
terraform init
```

以下コマンドを実行し、tfファイルに問題がないか確認。  
　Successと表示されればOK
```
terraform validate
```

以下コマンドを実行し、Terraformによるリソース作成を実行  
```
terraform apply
```

tfファイルを修正後、差分を確認したい場合は以下コマンドを実行する。  
```
terraform plan
```