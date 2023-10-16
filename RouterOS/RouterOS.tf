terraform {
  required_providers {
    routeros = {
      source = "vaerh/routeros"
    }
  }
}

provider "routeros" {
  hosturl        = var.mikrotik_url         # env ROS_HOSTURL or MIKROTIK_HOST
  username       = var.mikrotik_user                       # env ROS_USERNAME or MIKROTIK_USER
  password       = var.mikrotik_pass                             # env ROS_PASSWORD or MIKROTIK_PASSWORD
// ca_certificate = "routerCA.crt"  # env ROS_CA_CERTIFICATE or MIKROTIK_CA_CERTIFICATE
  insecure       = true                           # env ROS_INSECURE or MIKROTIK_INSECURE
}



data "routeros_ip_addresses" "external_ip" {
#  addresses = "10.10.10.10/24"
}