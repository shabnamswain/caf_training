###############################################################################
# Sandbox Landing Zone - Shared tfvars (one file for all trainees)
#
# Trainee identity is NOT stored here. The pipeline injects:
#   -var "user_alias=<branch leaf or parameter>"
# and the sandbox root module derives the VNet CIDR automatically from
# user_alias (e.g. user01 -> 10.1.0.0/16, user02 -> 10.2.0.0/16).
#
# Storage-account names must be globally unique. If apply fails with a
# name-conflict error, bump `instance` (e.g. 002, 003) until free.
###############################################################################

subscription_id = "58974d62-0f68-4856-8152-953266b7f10b"

location       = "eastus"
location_short = "eus"

workload    = "trn"       # training
environment = "sandbox"   # sandbox environment code
instance    = "001"

storage_account_tier        = "Standard"
storage_account_replication = "LRS"

# Cross-LZ diagnostics. Leave false until the Platform LZ has been applied at
# least once (this reads platform.tfstate via terraform_remote_state /azurerm).
# Backend coordinates default to rg-tfstate / sttfstatetrn001 / tfstate /
# platform.tfstate - override here only if your bootstrap stage used different
# names.
enable_diagnostics = false

tags = {
  environment = "sandbox"
  managed_by  = "terraform"
}
