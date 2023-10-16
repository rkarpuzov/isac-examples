resource "routeros_firewall_nat" "test_ssh" {
  dst_address_list = "DNAT_IP"
  src_address_list = "ACCESS"      # Access only from this list, remove for worldwide access
  dst_port      = "22022"
  comment = "ssh port forwarding"
  to_ports    = "22"
  to_addresses  = "10.10.10.20"
  action      = "dst-nat"
  chain       = "dstnat"
  protocol    = "tcp"
}
