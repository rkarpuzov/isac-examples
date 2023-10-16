# Create Container with Ubuntu 20.04 LTS, because dependancy of Zabbiz 5.x
resource "proxmox_lxc" "zabbix_lxc" {
  target_node  = var.prox_node
  hostname     = "zabbix"
  ostemplate   = "local:vztmpl/ubuntu-20.04-standard_20.04-1_amd64.tar.gz"
  unprivileged = true
  ostype = "ubuntu"  
  start = true
  ssh_public_keys = file("~/.ssh/id_rsa.pub")

  rootfs {
    storage = "local"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "10.10.10.104/8"
    gw     = "10.0.1.1"
  }
  
connection {
	type = "ssh"
	user = "root"
	host = "10.10.10.1"
	private_key = file("~/.ssh/id_rsa")
	bastion_host = var.bastion_host
	bastion_user = var.bastion_user
	bastion_private_key = file("~/.ssh/id_rsa")
}
  
      provisioner "file" {
    source = "./zabbix/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

    provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh",
    ]
  }
  
}

output "zabbix_address" {
	value = "${proxmox_lxc.zabbix_lxc.network[0].ip}"
	}
