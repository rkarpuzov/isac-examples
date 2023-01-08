
resource "proxmox_lxc" "ejabberd" {
  target_node     = var.prox_node
  hostname        = "ejabberd"
  ostemplate      = var.template_ubuntu
  unprivileged    = true
  ostype          = "ubuntu"
  vmid            = 102 
  start           = true
  ssh_public_keys = var.ssh_pub_key
  depends_on      = [proxmox_lxc.psqldb]

  connection {
    type                = "ssh"
    user                = "root"
    host                = "10.10.10.102"
    private_key         = file("~/.ssh/id_rsa")
    bastion_host        = var.bastion_host
    bastion_user        = var.bastion_user
    bastion_private_key = file("~/.ssh/id_rsa")
  }

  
  #provisioner "file" {
    #source      = "ejabberd/ssh/ssh_host_rsa_key"
    #destination = "/etc/ssh/ssh_host_rsa_key"
  #}
  #provisioner "file" {
    #source      = "ejabberd/ssh/ssh_host_ecdsa_key"
    #destination = "/etc/ssh/ssh_host_ecdsa_key"
  #}
  #provisioner "file" {
    #source      = "ejabberd/ssh/ssh_host_ed25519_key"
    #destination = "/etc/ssh/ssh_host_ed25519_key"
  #}

  provisioner "file" {
    source      = "ejabberd/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/bootstrap.sh",
      "sudo /tmp/bootstrap.sh",
    ]
  }

  rootfs {
    storage = "local"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "10.10.10.102/8"
    gw     = "10.0.1.1"
  }
}



output "jabber-ip_address" {
  value = proxmox_lxc.ejabberd.network[0].ip
}
