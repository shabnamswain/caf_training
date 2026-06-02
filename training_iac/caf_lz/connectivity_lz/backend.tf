terraform {
  backend "azurerm" {}
}

# Backend configuration is provided dynamically by Azure DevOps:
# - resource_group_name
# - storage_account_name
# - container_name
# - key
# The bootstrap stage creates the storage account and container before init.
