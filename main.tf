resource "azurerm_resource_group" "tf-nodejs-rg" {
  name     = "tf-nodejs-rg"
  location = "Central US"
}

resource "azurerm_virtual_network" "tf-vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${azurerm_resource_group.tf-nodejs-rg.name}"
  address_space       = "${var.vnet_address_space}"
  location            = "${azurerm_resource_group.tf-nodejs-rg.location}"
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = "${azurerm_resource_group.tf-nodejs-rg.name}"
  virtual_network_name = "${azurerm_virtual_network.tf-vnet.name}"
  address_prefix       = "${var.subnet}"
}

resource "azurerm_public_ip" "lb-pubip" {
  name                = "vip_tfnodejs-lb-pubip"
  location            = "${azurerm_resource_group.tf-nodejs-rg.location}"
  resource_group_name = "${azurerm_resource_group.tf-nodejs-rg.name}"
  allocation_method   = "Static"
}

resource "azurerm_lb" "tf-lb" {
  name                = "vip_tfnodejs-lb"
  location            = "${azurerm_resource_group.tf-nodejs-rg.location}"
  resource_group_name = "${azurerm_resource_group.tf-nodejs-rg.name}"

  frontend_ip_configuration {
    name                 = "vip_pubip"
    public_ip_address_id = "${azurerm_public_ip.lb-pubip.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "tf-pool" {
  resource_group_name = "${azurerm_resource_group.tf-nodejs-rg.name}"
  loadbalancer_id     = "${azurerm_lb.tf-lb.id}"
  name                = "backendpool"
}

resource "azurerm_lb_probe" "tf-probe" {
  resource_group_name = "${azurerm_resource_group.tf-nodejs-rg.name}"
  loadbalancer_id     = "${azurerm_lb.tf-lb.id}"
  name                = "tf-probe"
  protocol            = "tcp"
  port                = "${var.lbport}"
  interval_in_seconds = 5
  number_of_probes    = 2  
}

resource "azurerm_lb_rule" "tf-rule" {
  resource_group_name            = "${azurerm_resource_group.tf-nodejs-rg.name}"
  loadbalancer_id                = "${azurerm_lb.tf-lb.id}"
  name                           = "tf-rule"
  protocol                       = "tcp"
  frontend_port                  = 80
  backend_port                   = "${var.lbport}"
  frontend_ip_configuration_name = "vip_pubip"
  enable_floating_ip             = false
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.tf-pool.id}"
  probe_id                       = "${azurerm_lb_probe.tf-probe.id}"
  depends_on                     = ["azurerm_lb_probe.tf-probe"]
}

resource "azurerm_public_ip" "pubip" {
  name                         = "${var.vmname}-pip"
  location                     = "${azurerm_resource_group.tf-nodejs-rg.location}"
  resource_group_name          = "${azurerm_resource_group.tf-nodejs-rg.name}"
  public_ip_address_allocation = "Static"
  idle_timeout_in_minutes      = 30

}

resource "azurerm_network_interface" "vnic" {
  name                = "${var.vmname}-nic"
  location            = "${azurerm_resource_group.tf-nodejs-rg.location}"
  resource_group_name = "${azurerm_resource_group.tf-nodejs-rg.name}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pubip.id}" 
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.tf-pool.id}"]
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.vmname}"
  location              = "${azurerm_resource_group.tf-nodejs-rg.location}"
  resource_group_name   = "${azurerm_resource_group.tf-nodejs-rg.name}"
  network_interface_ids = ["${azurerm_network_interface.vnic.id}"]
  vm_size               = "Standard_D2_v3"

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.4"
    version   = "latest"
  }
  storage_os_disk {
    name              = "${var.vmname}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.vmname}"
    admin_username = "${var.username}"
    admin_password = "${var.password}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

}

data "azurerm_public_ip" "getip" {
  name                = "${azurerm_public_ip.pubip.name}"
  resource_group_name = "${azurerm_virtual_machine.vm.resource_group_name}"
}

output "public_ip_address" {
  value = "${data.azurerm_public_ip.getip.ip_address}"
}

resource "null_resource" "postaction" {
  
  connection {
    host = "${data.azurerm_public_ip.getip.ip_address}"
    type = "ssh"
    user = "${var.username}"
    password = "${var.password}"
    timeout = "5m"
  }
  
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/tmp/Dockerfile"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh",
    ]
  }
  depends_on = ["azurerm_virtual_machine.vm"]
}
