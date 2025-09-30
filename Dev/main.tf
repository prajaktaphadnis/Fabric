terraform {
  required_providers {
    azapi = {
        source = "azure/azapi"
        version = "~>2.0"
    }
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~>4.0"
    }
    }
  }

provider "azurerm" {
          features {}
          subscription_id = var.subscriptionid
          tenant_id = var.tenantid
        }

provider "azapi" {
  
}

resource "azurerm_resource_group" "example_rg" {
      name     = var.resourceGroup
      location = var.location
    }

resource "azapi_resource" "fab_capacity_dev" {
  type                      = "Microsoft.Fabric/capacities@2022-07-01-preview"
  name                      = var.CapacityDev
  parent_id                 = azurerm_resource_group.example_rg.id
  location                  = var.location
  schema_validation_enabled = false

  body = {
    properties = {
      administration = {
        members = [
          var.admin_email
        ]
      }
    }
    sku = {
      name = var.sku,
      tier = var.tier
    }
  }
  tags = var.tags
  count = var.module_enabled ? 1 : 0
}

resource "azurerm_key_vault" "fabkeyvault_dev" {
      name                        = "landp-dev-kv"
      location                    = var.location
      resource_group_name         = azurerm_resource_group.example_rg.name
      sku_name                    = "standard"
      tenant_id                   = var.tenantid
      soft_delete_retention_days  = 90
      purge_protection_enabled   = false
      
      network_acls {
        default_action = "Deny"
        bypass = "AzureServices"
        
      #   virtual_network_subnet_ids = [
      # azurerm_subnet.subnet_1.id
      #  ]
      }
    }

resource "azurerm_key_vault_access_policy" "kvaccesspolicy" {
  key_vault_id = azurerm_key_vault.fabkeyvault_dev.id
  tenant_id    = var.tenantid
  object_id    = "ad938f27-eb0b-4282-abc1-ec0f4b441368"

  key_permissions = [
    "Get", "List", "Encrypt", "Decrypt"
  ]

  secret_permissions = [
    "Get",
  ]
}

resource "azurerm_role_assignment" "key_vault_reader" {
  scope                = azurerm_key_vault.fabkeyvault_dev.id
  role_definition_name = "Key Vault Reader"
  principal_id         = "eszter.tatar@accenture.com"
}


resource "azurerm_virtual_network" "AzureVnet" {
      name                = "landp-dev-fabric-vnet01"
      location            = var.location
      resource_group_name = azurerm_resource_group.example_rg.name
      address_space       = ["192.168.90.0/24"]
    }

resource "azurerm_subnet" "subnet_1" {
      name                 = "landp-dev-paas-snet01"
      resource_group_name  = azurerm_resource_group.example_rg.name
      virtual_network_name = azurerm_virtual_network.AzureVnet.name
      address_prefixes     = ["192.168.90.0/25"]
      service_endpoints = ["Microsoft.KeyVault"]
    }


resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "landp-dev-privateendpoint"
  location            = var.location
  resource_group_name = azurerm_resource_group.example_rg.name
  subnet_id           = azurerm_subnet.subnet_1.id

  private_service_connection {
    name                           = "lanp-dev-kv-privateconnection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.fabkeyvault_dev.id
    subresource_names              = ["vault"] 
  }
}    

resource "azurerm_private_dns_zone" "privatedns" {
      name                = "privatelink.vault.azure.net" # Replace with your desired domain name
      resource_group_name = azurerm_resource_group.example_rg.name
    }

resource "azurerm_private_dns_zone_virtual_network_link" "privatednsnetwork" {
      name                  = "landp-dev-pdnslnk-vnet01"
      resource_group_name   = azurerm_resource_group.example_rg.name
      private_dns_zone_name = azurerm_private_dns_zone.privatedns.name
      virtual_network_id    = "/subscriptions/25877487-c39d-46b8-9e59-fd4688c0d4c2/resourceGroups/landp-rg-fabric-dev/providers/Microsoft.Network/virtualNetworks/landp-dev-fabric-vnet01"
    }