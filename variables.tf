variable "location" {
  type = string
  description = ""
  default = "uksouth"
}

variable "sku" {
  type = string
  default = "F2"
}

variable "admin_email" {
  type = string
  default = "nsomoza@londonandpartners.com"
}

variable "tier" {
  type = string
  default = "Fabric"
  
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags which should be assigned to the deployed resource."
}

variable "module_enabled" {
  type        = bool
  description = "Variable to enable or disable the module."
  default     = true
}

variable "resourceGroup" {
  type        = string
  default     = "landp-rg-fabric-dev"
}

variable "CapacityDev" {
  type        = string
  default     = "landpdevfabriccapacity"
}

variable "subscriptionid" {
  type        = string
  default     = "25877487-c39d-46b8-9e59-fd4688c0d4c2"
}

variable "tenantid" {
  type        = string
  default     = "a95c2981-bfa8-4c8b-81bb-dfcd208258b1"
}