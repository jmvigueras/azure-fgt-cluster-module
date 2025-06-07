#-------------------------------------------------------------------------------------------------------------
# FGT ACTIVE VM
#-------------------------------------------------------------------------------------------------------------
# Create new random API key to be provisioned in FortiGates.
resource "random_string" "vpn_psk" {
  length  = 30
  special = false
  numeric = true
}
# Create new random FGSP secret
resource "random_string" "api_key" {
  length  = 30
  special = false
  numeric = true
}
# Create new random auto-scale secret
resource "random_string" "auto_scale_secret" {
  length  = 10
  special = false
  numeric = false
}