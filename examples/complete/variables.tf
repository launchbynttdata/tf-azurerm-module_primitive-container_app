// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

variable "logical_product_family" {
  description = "Logical product family used for resource naming."
  type        = string
  default     = "launch"
}

variable "logical_product_service" {
  description = "Logical product service used for resource naming."
  type        = string
  default     = "caapp"
}

variable "class_env" {
  description = "Environment class used for resource naming."
  type        = string
  default     = "dev"
}

variable "instance_env" {
  description = "Numeric environment instance used for resource naming."
  type        = number
  default     = 0
}

variable "instance_resource" {
  description = "Numeric resource instance used for resource naming."
  type        = number
  default     = 0
}

variable "location" {
  description = "Azure region in which to deploy the example."
  type        = string
  default     = "eastus2"
}

variable "resource_names_map" {
  description = "Map of resource naming keys to cloud abbreviations and maximum lengths."
  type = map(object({
    name       = string
    max_length = number
  }))
}

variable "log_analytics_sku" {
  description = "SKU of the Log Analytics workspace used by the Container App Environment."
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_in_days" {
  description = "Log Analytics retention in days."
  type        = number
  default     = 30
}

variable "revision_mode" {
  description = "Revision mode passed to the Container App."
  type        = string
  default     = "Single"
}

variable "workload_profile_name" {
  description = "Workload profile passed to the Container App. Null uses Consumption."
  type        = string
  default     = null
}

variable "template" {
  description = "Container template passed to the Container App."
  type = object({
    container = list(object({
      name   = string
      image  = string
      cpu    = number
      memory = string
    }))
  })
  default = {
    container = [{
      name   = "app"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }]
  }
}

variable "ingress" {
  description = "Ingress passed to the Container App. external_enabled is false so the app is reachable only inside the environment."
  type = object({
    external_enabled = bool
    target_port      = number
    transport        = string
    traffic_weight = list(object({
      latest_revision = bool
      percentage      = number
    }))
  })
  default = {
    external_enabled = false
    target_port      = 80
    transport        = "auto"
    traffic_weight = [{
      latest_revision = true
      percentage      = 100
    }]
  }
}

variable "identity" {
  description = "Managed identity passed to the Container App."
  type = object({
    type = string
  })
  default = {
    type = "SystemAssigned"
  }
}

variable "registries" {
  description = "Container registries passed to the Container App."
  type = list(object({
    server               = string
    identity             = optional(string)
    username             = optional(string)
    password_secret_name = optional(string)
  }))
  default = []
}

variable "secrets" {
  description = "Secrets passed to the Container App."
  type = list(object({
    name                = string
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))
  default   = []
  sensitive = true
}

variable "dapr" {
  description = "Dapr sidecar passed to the Container App."
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string)
  })
  default = null
}

variable "max_inactive_revisions" {
  description = "Maximum inactive revisions passed to the Container App."
  type        = number
  default     = null
}

variable "tags" {
  description = "Tags to assign to example resources that support tags."
  type        = map(string)
  default     = {}
}
