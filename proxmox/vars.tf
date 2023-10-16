variable "prox_node" {
  description = "Proxmox VE node"
  type = string
  default = "pve"
}

variable "template_ubuntu" {
  description = "Ubuntu current LTS template for LXC. Adjust your vztmpl path and image file"
  type = string
  default = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "template_debian" {
  description = "Ubuntu current LTS template for LXC. Adjust your vztmpl path and image file"
  type = string
  default = "local:vztmpl/debian-11-standard_11.3-1_amd64.tar.zst"
}

variable "bastion_host" {
  description = "URL/IP to (for) your bastion host. This host will be used in creation and connection settings for deploy"
  type = string
  default = "bastion.example.tld"
}

variable "bastion_user" {
  description = "Username for your bastion host"
  type = string
  default = "bastion"
}

variable "ssh_pub_key" {
  description = "Root access via ssh pub key"
  type = string
  default = <<-EOT
ssh-rsa AAAA< user's id_ras.pub key. located in your ~/.ssh/id_rsa.pub= user@mylaptop
ssh-rsa AAAA< second user's pub key. Every user must be on new line  == user2@desktop
EOT
}

variable "default_gw" {
  description = "Root access via ssh pub key"
  type = string
  default = "10.10.10.1"
}
