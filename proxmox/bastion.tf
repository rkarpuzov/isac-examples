
resource "proxmox_lxc" "bastion" {
  target_node  = var.prox_node
  hostname     = "bastion"
  ostemplate   = var.template_ubuntu
  unprivileged = true
  ostype = "ubuntu"
  vmid = 101
  start = true
ssh_public_keys = var.ssh_pub_key


connection {
	type = "ssh"
	user = "root"
	host = var.bastion_host
	private_key = file("~/.ssh/id_rsa")
}

 provisioner "remote-exec" {
	inline = [
		"apt update",
		"apt upgrade -y",
		"apt install -y fail2ban",
		"systemctl start fail2ban",
        "useradd -m ${var.bastion_user}",
        "cp -r /root/.ssh /home/${var.bastion_user}",
        "chown -R ${var.bastion_user}. /home/${var.bastion_user}/.ssh",
	"iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE",
	"echo 1 > /proc/sys/net/ipv4/ip_forward",
     "echo @reboot /usr/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE | crontab -"
	]
	}

  ################## setup nginx as proxy
  provisioner "remote-exec" {
    inline = [
        "apt install -y nginx",
        "rm /etc/nginx/sites-enabled/default"
    ]
  }
  provisioner "file" {
    source = "bastion/movim.nginx"
    destination = "/etc/nginx/conf.d/movim.conf"
  }
########################### /proxy

  rootfs {
    storage = "local"
    size    = "8G"
  }

# The basic NC must be configured sregarding your service, ask your ISP for more info:
network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "1.2.3.4/32"
    hwaddr = "52:54:52:54:52:54"
    gw = "1.2.3.1"
  }

# Your virtual network inside the 
  network {
    name   = "eth1"
    bridge = "vmbr1"
    ip     = "10.10.10.1/8"
  }


}



output "bastion-ip_address1" {
	value = "${proxmox_lxc.bastion.network[1].ip}"
	}

output "bastion-ip_address0" {
	value = "${proxmox_lxc.bastion.network[0].ip}"
	}
