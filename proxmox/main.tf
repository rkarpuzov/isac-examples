terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = ">=2.9.3"
    }
  }
}

provider "proxmox" {
  # Configuration options
  pm_api_url      = "https://proxmox.example.tld:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
}
