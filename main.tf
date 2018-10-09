provider "azurerm" {
}
resource "azurerm_resource_group" "vpn" {
        name = "vpn-rg"
        location = "westus2"
}

resource "azurerm_virtual_network" "vpn" {
    name                = "vpn-vnet"
    address_space       = ["10.0.0.0/23"]
    location            = "westus2"
    resource_group_name = "vpn-rg"
}

resource "azurerm_subnet" "vpn-app-subnet" {
  name                 = "vpn-app-subnet"
  virtual_network_name = "${azurerm_virtual_network.vpn.name}"
  resource_group_name = "vpn-rg"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "gateway-subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = "vpn-rg"
  virtual_network_name = "vpn-vnet"
  address_prefix       = "10.0.1.0/24"
}




resource "azurerm_public_ip" "vpn-public-ip" {
  name                = "vpn-public-ip"
  location            = "westus2"
  resource_group_name = "vpn-rg"

  public_ip_address_allocation = "Dynamic"
  sku = "Basic"
}


resource "azurerm_virtual_network_gateway" "test" {
  name                = "vpn-vnet-gw"
  location            = "westus2"
  resource_group_name = "vpn-rg"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = "${azurerm_public_ip.vpn-public-ip.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.gateway-subnet.id}"
  }
}

resource "azurerm_local_network_gateway" "vpn-local-net-gw" {
  name                = "vpn-local-net-gw"
  resource_group_name = "vpn-rg"
  location            = "westus2"
  gateway_address     = "1.2.3.4"
  address_space       = ["192.168.1.0/24"]
}

resource "azurerm_virtual_network_gateway_connection" "vpn-local-net-gw-connection" {
  name                = "vpn-local-net-gw-connection"
  location            = "westus2"
  resource_group_name = "vpn-rg"

  type                       = "IPsec"
  virtual_network_gateway_id = "${azurerm_virtual_network_gateway.test.id}"
  local_network_gateway_id   = "${azurerm_local_network_gateway.vpn-local-net-gw.id}"

  shared_key = "changeme"
}
