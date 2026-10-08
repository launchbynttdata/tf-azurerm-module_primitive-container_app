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

variable "name" {
  description = "Name of the Container App. Must be 2-32 lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character. Changing this forces a new resource."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,30}[a-z0-9])$", var.name))
    error_message = "name must be 2-32 lowercase alphanumeric characters or hyphens, and must start and end with an alphanumeric character."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group containing the Container App Environment. Changing this forces a new resource."
  type        = string
}

variable "container_app_environment_id" {
  description = "Resource ID of the Container App Environment. Changing this forces a new resource."
  type        = string
}

variable "revision_mode" {
  description = "Revision mode. Single keeps one active revision. Multiple allows more than one, with traffic split in ingress.traffic_weight."
  type        = string

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be Single or Multiple."
  }
}

variable "workload_profile_name" {
  description = "Workload profile in the Container App Environment. Null uses the environment default (Consumption on a Consumption environment). Dedicated profiles are not limited to the Consumption CPU and memory pairs."
  type        = string
  default     = null
}

variable "template" {
  description = "App template. container is one or more containers. On Consumption, cpu and memory must be a documented pair such as 0.25 and 0.5Gi. Init containers, scale rules, and volumes are optional."
  type = object({
    container = list(object({
      name    = string
      image   = string
      cpu     = number
      memory  = string
      command = optional(list(string))
      args    = optional(list(string))
      env = optional(list(object({
        name        = string
        value       = optional(string)
        secret_name = optional(string)
      })), [])
      liveness_probe = optional(object({
        transport               = string
        port                    = number
        host                    = optional(string)
        path                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        timeout                 = optional(number)
        failure_count_threshold = optional(number)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
      }))
      readiness_probe = optional(object({
        transport               = string
        port                    = number
        host                    = optional(string)
        path                    = optional(string)
        interval_seconds        = optional(number)
        timeout                 = optional(number)
        failure_count_threshold = optional(number)
        success_count_threshold = optional(number)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
      }))
      startup_probe = optional(object({
        transport               = string
        port                    = number
        host                    = optional(string)
        path                    = optional(string)
        initial_delay           = optional(number)
        interval_seconds        = optional(number)
        timeout                 = optional(number)
        failure_count_threshold = optional(number)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
      }))
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string)
      })), [])
    }))
    init_container = optional(list(object({
      name    = string
      image   = string
      cpu     = optional(number)
      memory  = optional(string)
      command = optional(list(string))
      args    = optional(list(string))
      env = optional(list(object({
        name        = string
        value       = optional(string)
        secret_name = optional(string)
      })), [])
      volume_mounts = optional(list(object({
        name     = string
        path     = string
        sub_path = optional(string)
      })), [])
    })), [])
    min_replicas                     = optional(number)
    max_replicas                     = optional(number)
    cooldown_period_in_seconds       = optional(number)
    polling_interval_in_seconds      = optional(number)
    termination_grace_period_seconds = optional(number)
    revision_suffix                  = optional(string)
    azure_queue_scale_rule = optional(list(object({
      name         = string
      queue_name   = string
      queue_length = number
      authentication = list(object({
        secret_name       = string
        trigger_parameter = string
      }))
    })), [])
    custom_scale_rule = optional(list(object({
      name             = string
      custom_rule_type = string
      metadata         = map(string)
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    http_scale_rule = optional(list(object({
      name                = string
      concurrent_requests = number
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    tcp_scale_rule = optional(list(object({
      name                = string
      concurrent_requests = number
      authentication = optional(list(object({
        secret_name       = string
        trigger_parameter = string
      })), [])
    })), [])
    volume = optional(list(object({
      name          = string
      storage_name  = optional(string)
      storage_type  = optional(string)
      mount_options = optional(string)
    })), [])
  })

  validation {
    condition     = length(var.template.container) > 0
    error_message = "template.container must contain at least one container."
  }

  validation {
    condition = (
      var.template.min_replicas == null ||
      (var.template.min_replicas >= 0 && var.template.min_replicas <= 300 && floor(var.template.min_replicas) == var.template.min_replicas)
    )
    error_message = "template.min_replicas must be a whole number from 0 to 300."
  }

  validation {
    condition = (
      var.template.max_replicas == null ||
      (var.template.max_replicas >= 1 && var.template.max_replicas <= 300 && floor(var.template.max_replicas) == var.template.max_replicas)
    )
    error_message = "template.max_replicas must be a whole number from 1 to 300."
  }

  validation {
    condition = (
      var.template.min_replicas == null || var.template.max_replicas == null ||
      var.template.min_replicas <= var.template.max_replicas
    )
    error_message = "template.min_replicas must be less than or equal to template.max_replicas."
  }

  validation {
    condition = (
      var.template.cooldown_period_in_seconds == null ||
      (var.template.cooldown_period_in_seconds >= 1 && floor(var.template.cooldown_period_in_seconds) == var.template.cooldown_period_in_seconds)
    )
    error_message = "template.cooldown_period_in_seconds must be a whole number of at least 1."
  }

  validation {
    condition = (
      var.template.polling_interval_in_seconds == null ||
      (var.template.polling_interval_in_seconds >= 1 && floor(var.template.polling_interval_in_seconds) == var.template.polling_interval_in_seconds)
    )
    error_message = "template.polling_interval_in_seconds must be a whole number of at least 1."
  }

  validation {
    condition = (
      var.template.termination_grace_period_seconds == null ||
      (var.template.termination_grace_period_seconds >= 0 && var.template.termination_grace_period_seconds <= 600 && floor(var.template.termination_grace_period_seconds) == var.template.termination_grace_period_seconds)
    )
    error_message = "template.termination_grace_period_seconds must be a whole number from 0 to 600."
  }

  validation {
    condition = alltrue([
      for container in var.template.container : container.cpu >= 0.1
    ])
    error_message = "Each container cpu must be at least 0.1."
  }

  validation {
    condition = alltrue(flatten([
      for container in var.template.container : [
        contains(["TCP", "HTTP", "HTTPS"], try(container.liveness_probe.transport, "HTTP")),
        try(container.liveness_probe.port, 1) >= 1 && try(container.liveness_probe.port, 1) <= 65535,
        try(container.liveness_probe.transport, "HTTP") != "TCP" || try(container.liveness_probe.path, null) == null,
        try(container.liveness_probe.initial_delay, 0) >= 0 && try(container.liveness_probe.initial_delay, 0) <= 60,
        try(container.liveness_probe.interval_seconds, 1) >= 1 && try(container.liveness_probe.interval_seconds, 1) <= 240,
        try(container.liveness_probe.timeout, 1) >= 1 && try(container.liveness_probe.timeout, 1) <= 240,
        try(container.liveness_probe.failure_count_threshold, 1) >= 1 && try(container.liveness_probe.failure_count_threshold, 1) <= 30,
      ] if container.liveness_probe != null
    ]))
    error_message = "liveness_probe transport must be TCP, HTTP, or HTTPS; port must be 1-65535; path is only valid for HTTP and HTTPS; initial_delay must be 0-60; interval_seconds and timeout must be 1-240; failure_count_threshold must be 1-30."
  }

  validation {
    condition = alltrue(flatten([
      for container in var.template.container : [
        contains(["TCP", "HTTP", "HTTPS"], container.readiness_probe.transport),
        container.readiness_probe.port >= 1 && container.readiness_probe.port <= 65535,
        container.readiness_probe.transport != "TCP" || container.readiness_probe.path == null,
        try(container.readiness_probe.interval_seconds, 1) >= 1 && try(container.readiness_probe.interval_seconds, 1) <= 240,
        try(container.readiness_probe.timeout, 1) >= 1 && try(container.readiness_probe.timeout, 1) <= 240,
        try(container.readiness_probe.failure_count_threshold, 1) >= 1 && try(container.readiness_probe.failure_count_threshold, 1) <= 48,
        try(container.readiness_probe.success_count_threshold, 1) >= 1 && try(container.readiness_probe.success_count_threshold, 1) <= 10,
      ] if container.readiness_probe != null
    ]))
    error_message = "readiness_probe transport must be TCP, HTTP, or HTTPS; port must be 1-65535; path is only valid for HTTP and HTTPS; interval_seconds and timeout must be 1-240; failure_count_threshold must be 1-48; success_count_threshold must be 1-10."
  }

  validation {
    condition = alltrue(flatten([
      for container in var.template.container : [
        contains(["TCP", "HTTP", "HTTPS"], container.startup_probe.transport),
        container.startup_probe.port >= 1 && container.startup_probe.port <= 65535,
        container.startup_probe.transport != "TCP" || container.startup_probe.path == null,
        try(container.startup_probe.interval_seconds, 1) >= 1 && try(container.startup_probe.interval_seconds, 1) <= 240,
        try(container.startup_probe.timeout, 1) >= 1 && try(container.startup_probe.timeout, 1) <= 240,
        try(container.startup_probe.failure_count_threshold, 1) >= 1 && try(container.startup_probe.failure_count_threshold, 1) <= 240,
        try(container.startup_probe.initial_delay, 0) >= 0 && try(container.startup_probe.initial_delay, 0) <= 60,
      ] if container.startup_probe != null
    ]))
    error_message = "startup_probe transport must be TCP, HTTP, or HTTPS; port must be 1-65535; path is only valid for HTTP and HTTPS; initial_delay must be 0-60; interval_seconds and timeout must be 1-240; failure_count_threshold must be 1-240."
  }

  validation {
    condition = alltrue([
      for volume in var.template.volume :
      (try(volume.storage_type, null) == null || contains(["AzureFile", "EmptyDir"], volume.storage_type)) &&
      (try(volume.storage_type, "EmptyDir") != "AzureFile" || volume.storage_name != null)
    ])
    error_message = "volume.storage_type must be AzureFile or EmptyDir. storage_name is required when storage_type is AzureFile."
  }
}

variable "ingress" {
  description = "Ingress for the app. external_enabled defaults to false in the provider when omitted here. traffic_weight percentages must sum to 100. exposed_port is only valid when transport is tcp. When a Key Vault certificate hostname is required, use azurerm_container_app_custom_domain; ingress.custom_domain is computed in azurerm 4.x and is not an input."
  type = object({
    allow_insecure_connections = optional(bool)
    external_enabled           = optional(bool)
    target_port                = number
    exposed_port               = optional(number)
    transport                  = optional(string)
    client_certificate_mode    = optional(string)
    traffic_weight = list(object({
      label           = optional(string)
      latest_revision = optional(bool, false)
      percentage      = number
      revision_suffix = optional(string)
    }))
    ip_security_restriction = optional(list(object({
      action           = string
      description      = optional(string)
      ip_address_range = string
      name             = string
    })), [])
    cors = optional(object({
      allowed_origins           = list(string)
      allow_credentials_enabled = optional(bool)
      allowed_headers           = optional(list(string), [])
      allowed_methods           = optional(list(string), [])
      exposed_headers           = optional(list(string), [])
      max_age_in_seconds        = optional(number)
    }))
  })
  default = null

  validation {
    condition = var.ingress == null || (
      var.ingress.target_port >= 1 && var.ingress.target_port <= 65535 &&
      (var.ingress.transport == null || contains(["auto", "http", "http2", "tcp"], var.ingress.transport)) &&
      (var.ingress.transport == "tcp" || var.ingress.exposed_port == null) &&
      (var.ingress.exposed_port == null || (var.ingress.exposed_port >= 1 && var.ingress.exposed_port <= 65535)) &&
      length(var.ingress.traffic_weight) > 0 &&
      sum([for weight in var.ingress.traffic_weight : weight.percentage]) == 100 &&
      length([for weight in var.ingress.traffic_weight : weight if weight.latest_revision]) <= 1 &&
      alltrue([for weight in var.ingress.traffic_weight : weight.latest_revision || weight.revision_suffix != null]) &&
      alltrue([for weight in var.ingress.traffic_weight : weight.percentage >= 0 && weight.percentage <= 100 && floor(weight.percentage) == weight.percentage]) &&
      length(distinct([for rule in var.ingress.ip_security_restriction : rule.action])) <= 1 &&
      alltrue([for rule in var.ingress.ip_security_restriction : contains(["Allow", "Deny"], rule.action)]) &&
      (var.ingress.client_certificate_mode == null || contains(["accept", "require", "ignore"], var.ingress.client_certificate_mode)) &&
      (var.ingress.cors == null || var.ingress.cors.max_age_in_seconds == null || var.ingress.cors.max_age_in_seconds >= 0)
    )
    error_message = "ingress target_port must be 1-65535; transport must be auto, http, http2, or tcp; exposed_port is only valid when transport is tcp; traffic_weight percentages must be whole numbers that sum to 100; at most one weight may set latest_revision; a weight with latest_revision false must set revision_suffix; ip_security_restriction actions must all be Allow or all be Deny; client_certificate_mode must be accept, require, or ignore; cors.max_age_in_seconds must be at least 0."
  }
}

variable "registries" {
  description = "Container registries. Each entry uses either identity or username plus password_secret_name."
  type = list(object({
    server               = string
    identity             = optional(string)
    username             = optional(string)
    password_secret_name = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for registry in var.registries :
      (registry.identity != null && registry.username == null && registry.password_secret_name == null) ||
      (registry.identity == null && registry.username != null && registry.password_secret_name != null)
    ])
    error_message = "Each registry must use either identity or username plus password_secret_name, not both and not neither."
  }
}

variable "secrets" {
  description = "Secrets available to the app. Set value for a literal secret, or key_vault_secret_id together with identity (a user-assigned identity resource ID, or System). Do not set both value and key_vault_secret_id. When key_vault_secret_id is used, the provider ignores value and recommends that the caller ignore changes to value."
  type = list(object({
    name                = string
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))
  default   = []
  sensitive = true

  validation {
    condition = alltrue([
      for secret in var.secrets :
      (secret.value != null && secret.key_vault_secret_id == null && secret.identity == null) ||
      (secret.value == null && secret.key_vault_secret_id != null && secret.identity != null)
    ])
    error_message = "Each secret must set value, or key_vault_secret_id together with identity. Do not combine value with a Key Vault reference."
  }
}

variable "identity" {
  description = "Managed identity. type is SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None. identity_ids is required for UserAssigned and SystemAssigned, UserAssigned."
  type = object({
    type         = string
    identity_ids = optional(list(string), [])
  })
  default = null

  validation {
    condition = var.identity == null || (
      contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "None"], var.identity.type) &&
      (!contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) || length(var.identity.identity_ids) > 0)
    )
    error_message = "identity.type must be SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None. identity_ids is required when type includes UserAssigned."
  }
}

variable "dapr" {
  description = "Dapr sidecar. app_protocol is http or grpc."
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string)
  })
  default = null

  validation {
    condition = var.dapr == null || (
      (var.dapr.app_protocol == null || contains(["http", "grpc"], var.dapr.app_protocol)) &&
      (var.dapr.app_port == null || (var.dapr.app_port >= 1 && var.dapr.app_port <= 65535 && floor(var.dapr.app_port) == var.dapr.app_port))
    )
    error_message = "dapr.app_protocol must be http or grpc. dapr.app_port must be a whole number from 1 to 65535."
  }
}

variable "max_inactive_revisions" {
  description = "Maximum number of inactive revisions kept for this Container App."
  type        = number
  default     = null

  validation {
    condition = (
      var.max_inactive_revisions == null ||
      (var.max_inactive_revisions >= 0 && var.max_inactive_revisions <= 100 && floor(var.max_inactive_revisions) == var.max_inactive_revisions)
    )
    error_message = "max_inactive_revisions must be a whole number from 0 to 100."
  }
}

variable "tags" {
  description = "Tags assigned to the Container App."
  type        = map(string)
  default     = {}
}
