

# ----------------------------
# Resource Group
# ----------------------------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
    tags = {
    businesscriticality = var.resource_tags.businesscriticality
    businessunit        = var.resource_tags.businessunit
    costcentre         = var.resource_tags.costcentre
    dataclassification = var.resource_tags.dataclassification
    workloadname       = var.resource_tags.workloadname
  }
}

# ----------------------------
# Virtual Network + Subnet
# ----------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_cidr]
}

# ----------------------------
# Master NSG
# ----------------------------
resource "azurerm_network_security_group" "master_nsg" {
  name                = "${var.prefix}-master-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                        = "AllowSSH"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.admin_public_ip]
    source_port_range            = "*"
    destination_port_range       = 22
    destination_address_prefix   = "*"
  }

  security_rule {
    name                        = "AllowKubeAPI"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.vnet_cidr, var.admin_public_ip]
    source_port_range            = "*"
    destination_port_range       = 6443
    destination_address_prefix   = "*"
  }

  security_rule {
    name                        = "AllowEtcdClient"
    priority                    = 120
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.vnet_cidr]
    source_port_range            = "*"
    destination_port_ranges      = ["2379-2380"]
    destination_address_prefix   = "*"
  }

  security_rule {
    name                        = "AllowControlPlane"
    priority                    = 130
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.vnet_cidr]
    source_port_range            = "*"
    destination_port_ranges      = ["10248-10260"]
    destination_address_prefix   = "*"
  }
}


# ----------------------------
# Worker NSG
# ----------------------------
resource "azurerm_network_security_group" "worker_nsg" {
  name                = "${var.prefix}-worker-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                        = "AllowSSH"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.admin_public_ip]
    source_port_range            = "*"
    destination_port_range       = 22
    destination_address_prefix   = "*"
  }

  security_rule {
    name                        = "AllowKubeletAPI"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.vnet_cidr]
    source_port_range            = "*"
    destination_port_range       = 10250
    destination_address_prefix   = "*"
  }

  security_rule {
    name                        = "AllowKubeProxy"
    priority                    = 120
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.vnet_cidr]
    source_port_range            = "*"
    destination_port_range       = 10256
    destination_address_prefix   = "*"
  }

  security_rule {
    name                        = "AllowNodePortTCP"
    priority                    = 130
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_address_prefixes      = [var.vnet_cidr]
    source_port_range            = "*"
    destination_port_ranges      = ["30000-32767"]
    destination_address_prefix   = "*"
  }

  security_rule {
    name                        = "AllowNodePortUDP"
    priority                    = 140
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Udp"
    source_address_prefixes      = [var.vnet_cidr]
    source_port_range            = "*"
    destination_port_ranges      = ["30000-32767"]
    destination_address_prefix   = "*"
  }
}


# ----------------------------
# Public IPs, NICs, and VMs
# ----------------------------
# Master Node
resource "azurerm_public_ip" "master_ip" {
  name                = "${var.prefix}-master-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "master_nic" {
  name                = "${var.prefix}-master-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.master_ip.id
  }

}

resource "azurerm_network_interface_security_group_association" "master_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.master_nic.id
  network_security_group_id = azurerm_network_security_group.master_nsg.id
}


resource "azurerm_linux_virtual_machine" "master" {
  name                = "${var.prefix}-master"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.master_nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    Role = "master"
  }
}

# Worker Nodes
resource "azurerm_public_ip" "worker_ips" {
  count               = var.node_count
  name                = "${var.prefix}-worker${count.index + 1}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "worker_nics" {
  count               = var.node_count
  name                = "${var.prefix}-worker${count.index + 1}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.worker_ips[count.index].id
  }

}

resource "azurerm_network_interface_security_group_association" "worker_nsg_assoc" {
  count                     = var.node_count
  network_interface_id      = azurerm_network_interface.worker_nics[count.index].id
  network_security_group_id = azurerm_network_security_group.worker_nsg.id
}

resource "azurerm_linux_virtual_machine" "workers" {
  count               = var.node_count
  name                = "${var.prefix}-worker${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.worker_nics[count.index].id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = {
    Role = "worker"
  }
}