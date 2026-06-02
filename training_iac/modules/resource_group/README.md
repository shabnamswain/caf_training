# Resource Group Module

Creates a single Azure Resource Group.

The caller is expected to pass a CAF-compliant name (e.g. `rg-trn-sbx-u01-eus-001`); this module does not build names itself, so it can be reused in any landing zone.

## Usage

```hcl
module "rg" {
  source = "../../modules/resource_group"

  name     = "rg-trn-sbx-u01-eus-001"
  location = "eastus"

  tags = {
    environment = "sandbox"
    managed_by  = "terraform"
  }
}
```

## Requirements

| Name      | Version       |
| --------- | ------------- |
| terraform | >= 1.5.0      |
| azurerm   | >= 4.0, < 5.0 |

## Inputs

| Name     | Type          | Default | Required | Description                                                                |
| -------- | ------------- | ------- | -------- | -------------------------------------------------------------------------- |
| name     | `string`      | n/a     | yes      | Resource group name (1-90 chars). Caller passes a CAF-compliant name.      |
| location | `string`      | n/a     | yes      | Azure region (e.g. `eastus`).                                              |
| tags     | `map(string)` | `{}`    | no       | Tags applied to the resource group.                                        |

## Outputs

| Name     | Description                          |
| -------- | ------------------------------------ |
| id       | Resource ID of the resource group.   |
| name     | Name of the resource group.          |
| location | Azure region of the resource group.  |

## Notes

- No provider block is declared here. The root module owns the `provider "azurerm"` configuration.
- A `validation` rule enforces the 1-90 character length limit imposed by Azure.
