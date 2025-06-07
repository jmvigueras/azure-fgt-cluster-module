output "config" {
  description = "FortiGate configuration output"
  #sensitive   = true
  value = local.fgt_config
}

output "vpn_psk" {
  description = "VPN Pre-Shared Key (PSK)"
  sensitive   = true
  value       = try(lookup(var.hub[0], "vpn_psk"), random_string.vpn_psk.result)
}

output "api_key" {
  description = "API Key for FortiGate instance"
  sensitive   = true
  value       = var.api_key == null ? random_string.api_key.result : var.api_key
}

output "auto_scale_secret" {
  description = "Auto Scale Secret"
  sensitive   = true
  value       = local.auto_scale_secret
}



