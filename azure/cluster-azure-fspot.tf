provider "azurerm" {
  version = ">=2.00.0"
  features {}
}

variable "instance_count" {
  description = "Defines the number of VMs to be provisioned."
  #default     = "2"
}
variable "app_name" {
  description = "Application Name"
  default     = "FVCOM"
}

variable "resource_location" {
  description = "Location of the infrastructure"
  #default     = "South Central US"
  default     = "East US"
}

variable "instance_size" {
  description = "Size of the instance"
  #default = "Standard_F32s_v2"
  #default = "Standard_F64s_v2"
  default = "Standard_F72s_v2"
  #default = "Standard_B2ms"
  #default = "Standard_H16r"
  #default = "Standard_Hc44rs"
  #default = "Standard_Hb60rs"
}

variable "accelerated" {
  description = "List of accelerated instance sizes"
  default = [
    "Standard_F32s_v2",
    "Standard_F64s_v2",
    "Standard_F72s_v2",
    "Standard_HB120rs"
    #"Standard_Hc44rs",
    #"Standard_Hb60rs"
  ]
}
data "azurerm_shared_image" "hpc-sig-image" {
  name                = "ompi"
  gallery_name        = "hpcimages"
  resource_group_name = "packer-hpc-rg"
}

resource "azurerm_resource_group" "RG" {
  name     = "HPC-${upper(var.app_name)}-RG"
  location = var.resource_location
}

# Use existing HPC-Network resource group
data "azurerm_resource_group" "network-rg" {
  name = "HPC-Network"
}

# Use existing HPC-VNET
data "azurerm_virtual_network" "vnet" {
  #name                = "HPC-VNET-SC"
  name                = "HPC-VNET"
  resource_group_name = "${data.azurerm_resource_group.network-rg.name}"
}

data "azurerm_subnet" "subnet" {
  name                 = "default"
  virtual_network_name = "${data.azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${data.azurerm_resource_group.network-rg.name}"
}

resource "azurerm_public_ip" "pip" {
  name                = "${lower(var.app_name)}-vm${count.index + 1}-pip"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  allocation_method   = "Static"
  count               = var.instance_count
}

resource "azurerm_network_interface" "vnic" {
  count                         = var.instance_count
  name                          = "hpc-${lower(var.app_name)}-nic${count.index + 1}"
  location                      = azurerm_resource_group.RG.location
  resource_group_name           = azurerm_resource_group.RG.name
  enable_accelerated_networking = contains(var.accelerated, var.instance_size) ? true : false

  ip_configuration {
    name                          = "testConfiguration"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pip.*.id, count.index)
  }
}

resource "azurerm_proximity_placement_group" "hpcplacement" {
  name                = "hpcplacementgroup"
  location            = azurerm_resource_group.RG.location
  resource_group_name = azurerm_resource_group.RG.name
  }

resource "azurerm_linux_virtual_machine" "vm" {
  count                             = var.instance_count
  name                              = "hpc-${lower(var.app_name)}-vm${count.index + 1}"
  location                          = azurerm_resource_group.RG.location
  proximity_placement_group_id     = azurerm_proximity_placement_group.hpcplacement.id
  resource_group_name               = azurerm_resource_group.RG.name
  network_interface_ids             = [element(azurerm_network_interface.vnic.*.id, count.index)]
  size                              = var.instance_size

  source_image_id                   = data.azurerm_shared_image.hpc-sig-image.id

  os_disk {
    name                             = "osdisk${count.index + 1}"
    caching                         = "ReadWrite"
    storage_account_type            = "StandardSSD_LRS"
    disk_size_gb                    = "64"
  }
  computer_name                     = "hpc-${lower(var.app_name)}-vm${count.index + 1}"
  admin_username                    = "ubuntu"

  admin_ssh_key {
    username              = "ubuntu"
    public_key            = file("~/ubuntu.key.pub")
  }

  priority                = "Spot"
  max_bid_price           = "0.65"
  eviction_policy         = "Deallocate"
  
}

resource "null_resource" "prep_ansible" {
  triggers = {
    build_number = "${timestamp()}"
  }
  depends_on = [azurerm_linux_virtual_machine.vm]

  provisioner "local-exec" {
    command = "echo [default] ${join(" ", azurerm_public_ip.pip.*.ip_address)} | tr \" \" \"\n\" > ansible.hosts"
  }
  provisioner "local-exec" {
    command = "echo ${join("@", formatlist("Host %s @  User ubuntu@  Hostname %s@  IdentityFile ~/ubuntu.key", azurerm_network_interface.vnic.*.name, azurerm_public_ip.pip.*.ip_address))} | tr \"@\" \"\n\" > ~/vscode.hosts"
  }
}

output "pips_for_ansible_hosts" {
  value = "${azurerm_public_ip.pip.*.ip_address}"
}

output "ime" {
  value = "${formatlist("%s", azurerm_public_ip.pip.*.ip_address)}"
}
