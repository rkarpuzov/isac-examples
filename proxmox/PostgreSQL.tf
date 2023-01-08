
resource "proxmox_lxc" "psqldb" {
  vmid = 103
  target_node  = var.prox_node
  hostname     = "psqldb"
  ostemplate   = var.template_ubuntu
  unprivileged = true
  ostype = "ubuntu"
  start = true
  cores=4
  cpuunits=4096
  cpulimit=4
  memory=4096
  swap=1024
    features {
    nesting = true
  }
ssh_public_keys = var.ssh_pub_key


connection {
	type = "ssh"
	user = "root"
	host = "10.10.10.101"
	private_key = file("~/.ssh/id_rsa")
	bastion_host = var.bastion_host
	bastion_user = var.bastion_user
	bastion_private_key = file("~/.ssh/id_rsa")
}

    provisioner "file" {
    source = "./postgresql/bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  #provisioner "file" {
    #source = "postgresql/ssh/ssh_host_rsa_key"
    #destination = "/etc/ssh/ssh_host_rsa_key"
  #}
    #provisioner "file" {
    #source = "postgresql/ssh/ssh_host_ecdsa_key"
    #destination = "/etc/ssh/ssh_host_ecdsa_key"
  #}
    #provisioner "file" {
    #source = "postgresql/ssh/ssh_host_ed25519_key"
    #destination = "/etc/ssh/ssh_host_ed25519_key"
  #}
  #provisioner "remote-exec" {
    #inline = [
      #"sudo chmod +x /tmp/bootstrap.sh",
      #"sudo /tmp/bootstrap.sh",
    #]
  #}

# Create DB user for movim  # pg_hba.conf is changed as pre_install.sh echoes lines
 provisioner "remote-exec" {
	inline = [
      "sudo -u postgres createdb movim",
      "sudo -u postgres createuser -w movim",
      "sudo -u postgres psql -c \"ALTER USER movim WITH PASSWORD 'examplepass'\"",
      "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE movim TO movim\"",
      "systemctl restart postgresql",
	]
	}
# Create DB user for ejabberd # pg_hba.conf inline changes
  provisioner "remote-exec" {
	inline = [
      "sudo -u postgres createdb ejabberd",
      "sudo -u postgres createuser -w ejabberd",
      "sudo -u postgres psql -c \"ALTER USER ejabberd WITH PASSWORD 'example_pass'\"",
      "sudo -u postgres psql -c \"GRANT ALL PRIVILEGES ON DATABASE ejabberd TO ejabberd\"",
      "echo host all ejabberd 10.10.10.102/32 trust >> /etc/postgresql/14/main/pg_hba.conf",
      "echo host all ejabberd 0.0.0.0/0 md5 >> /etc/postgresql/14/main/pg_hba.conf",
      "echo host all ejabberd ::0/0 md5 >> /etc/postgresql/14/main/pg_hba.conf",
      "systemctl restart postgresql",
	]
	}

  rootfs {
    storage = "local"
    size    = "8G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr1"
    ip     = "10.10.10.101/8"
    gw = "10.0.1.1"
  }
}



output "ip_address3" {
	value = "${proxmox_lxc.psqldb.network[0].ip}"
	}

