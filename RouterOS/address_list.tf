resource "routeros_firewall_addr_list" "access_granted_1" {
  address = "10.10.10.101"
  list = "ACCESS"
  comment = "Server1 access granted"
}
