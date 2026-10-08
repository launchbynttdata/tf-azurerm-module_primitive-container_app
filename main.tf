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

resource "azurerm_container_app" "container_app" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name
  max_inactive_revisions       = var.max_inactive_revisions
  tags                         = var.tags

  template {
    min_replicas                     = var.template.min_replicas
    max_replicas                     = var.template.max_replicas
    cooldown_period_in_seconds       = var.template.cooldown_period_in_seconds
    polling_interval_in_seconds      = var.template.polling_interval_in_seconds
    termination_grace_period_seconds = var.template.termination_grace_period_seconds
    revision_suffix                  = var.template.revision_suffix

    dynamic "container" {
      for_each = var.template.container
      content {
        name    = container.value.name
        image   = container.value.image
        cpu     = container.value.cpu
        memory  = container.value.memory
        command = container.value.command
        args    = container.value.args

        dynamic "env" {
          for_each = container.value.env
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        dynamic "liveness_probe" {
          for_each = container.value.liveness_probe == null ? [] : [container.value.liveness_probe]
          content {
            transport               = liveness_probe.value.transport
            port                    = liveness_probe.value.port
            host                    = liveness_probe.value.host
            path                    = liveness_probe.value.path
            initial_delay           = liveness_probe.value.initial_delay
            interval_seconds        = liveness_probe.value.interval_seconds
            timeout                 = liveness_probe.value.timeout
            failure_count_threshold = liveness_probe.value.failure_count_threshold

            dynamic "header" {
              for_each = liveness_probe.value.header
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "readiness_probe" {
          for_each = container.value.readiness_probe == null ? [] : [container.value.readiness_probe]
          content {
            transport               = readiness_probe.value.transport
            port                    = readiness_probe.value.port
            host                    = readiness_probe.value.host
            path                    = readiness_probe.value.path
            interval_seconds        = readiness_probe.value.interval_seconds
            timeout                 = readiness_probe.value.timeout
            failure_count_threshold = readiness_probe.value.failure_count_threshold
            success_count_threshold = readiness_probe.value.success_count_threshold

            dynamic "header" {
              for_each = readiness_probe.value.header
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "startup_probe" {
          for_each = container.value.startup_probe == null ? [] : [container.value.startup_probe]
          content {
            transport               = startup_probe.value.transport
            port                    = startup_probe.value.port
            host                    = startup_probe.value.host
            path                    = startup_probe.value.path
            initial_delay           = startup_probe.value.initial_delay
            interval_seconds        = startup_probe.value.interval_seconds
            timeout                 = startup_probe.value.timeout
            failure_count_threshold = startup_probe.value.failure_count_threshold

            dynamic "header" {
              for_each = startup_probe.value.header
              content {
                name  = header.value.name
                value = header.value.value
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = container.value.volume_mounts
          content {
            name     = volume_mounts.value.name
            path     = volume_mounts.value.path
            sub_path = volume_mounts.value.sub_path
          }
        }
      }
    }

    dynamic "init_container" {
      for_each = var.template.init_container
      content {
        name    = init_container.value.name
        image   = init_container.value.image
        cpu     = init_container.value.cpu
        memory  = init_container.value.memory
        command = init_container.value.command
        args    = init_container.value.args

        dynamic "env" {
          for_each = init_container.value.env
          content {
            name        = env.value.name
            value       = env.value.value
            secret_name = env.value.secret_name
          }
        }

        dynamic "volume_mounts" {
          for_each = init_container.value.volume_mounts
          content {
            name     = volume_mounts.value.name
            path     = volume_mounts.value.path
            sub_path = volume_mounts.value.sub_path
          }
        }
      }
    }

    dynamic "volume" {
      for_each = var.template.volume
      content {
        name          = volume.value.name
        storage_name  = volume.value.storage_name
        storage_type  = volume.value.storage_type
        mount_options = volume.value.mount_options
      }
    }

    dynamic "azure_queue_scale_rule" {
      for_each = var.template.azure_queue_scale_rule
      content {
        name         = azure_queue_scale_rule.value.name
        queue_name   = azure_queue_scale_rule.value.queue_name
        queue_length = azure_queue_scale_rule.value.queue_length

        dynamic "authentication" {
          for_each = azure_queue_scale_rule.value.authentication
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "custom_scale_rule" {
      for_each = var.template.custom_scale_rule
      content {
        name             = custom_scale_rule.value.name
        custom_rule_type = custom_scale_rule.value.custom_rule_type
        metadata         = custom_scale_rule.value.metadata

        dynamic "authentication" {
          for_each = custom_scale_rule.value.authentication
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "http_scale_rule" {
      for_each = var.template.http_scale_rule
      content {
        name                = http_scale_rule.value.name
        concurrent_requests = http_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = http_scale_rule.value.authentication
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }

    dynamic "tcp_scale_rule" {
      for_each = var.template.tcp_scale_rule
      content {
        name                = tcp_scale_rule.value.name
        concurrent_requests = tcp_scale_rule.value.concurrent_requests

        dynamic "authentication" {
          for_each = tcp_scale_rule.value.authentication
          content {
            secret_name       = authentication.value.secret_name
            trigger_parameter = authentication.value.trigger_parameter
          }
        }
      }
    }
  }

  dynamic "ingress" {
    for_each = var.ingress == null ? [] : [var.ingress]
    content {
      allow_insecure_connections = ingress.value.allow_insecure_connections
      external_enabled           = ingress.value.external_enabled
      target_port                = ingress.value.target_port
      exposed_port               = ingress.value.exposed_port
      transport                  = ingress.value.transport
      client_certificate_mode    = ingress.value.client_certificate_mode

      dynamic "traffic_weight" {
        for_each = ingress.value.traffic_weight
        content {
          label           = traffic_weight.value.label
          latest_revision = traffic_weight.value.latest_revision
          percentage      = traffic_weight.value.percentage
          revision_suffix = traffic_weight.value.revision_suffix
        }
      }

      dynamic "ip_security_restriction" {
        for_each = ingress.value.ip_security_restriction
        content {
          action           = ip_security_restriction.value.action
          description      = ip_security_restriction.value.description
          ip_address_range = ip_security_restriction.value.ip_address_range
          name             = ip_security_restriction.value.name
        }
      }

      dynamic "cors" {
        for_each = ingress.value.cors == null ? [] : [ingress.value.cors]
        content {
          allowed_origins           = cors.value.allowed_origins
          allow_credentials_enabled = cors.value.allow_credentials_enabled
          allowed_headers           = cors.value.allowed_headers
          allowed_methods           = cors.value.allowed_methods
          exposed_headers           = cors.value.exposed_headers
          max_age_in_seconds        = cors.value.max_age_in_seconds
        }
      }
    }
  }

  dynamic "registry" {
    for_each = var.registries
    content {
      server               = registry.value.server
      identity             = registry.value.identity
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name                = secret.value.name
      value               = secret.value.value
      key_vault_secret_id = secret.value.key_vault_secret_id
      identity            = secret.value.identity
    }
  }

  dynamic "identity" {
    for_each = var.identity == null || var.identity.type == "None" ? [] : [var.identity]
    content {
      type         = identity.value.type
      identity_ids = length(identity.value.identity_ids) == 0 ? null : identity.value.identity_ids
    }
  }

  dynamic "dapr" {
    for_each = var.dapr == null ? [] : [var.dapr]
    content {
      app_id       = dapr.value.app_id
      app_port     = dapr.value.app_port
      app_protocol = dapr.value.app_protocol
    }
  }

  lifecycle {
    precondition {
      condition = var.workload_profile_name != null || alltrue([
        for container in local.consumption_containers : anytrue([
          for pair in local.consumption_pairs : container.cpu == pair.cpu && contains(pair.memory, container.memory)
        ])
      ])
      error_message = "On the Consumption profile, each container cpu and memory must be a documented pair (for example 0.25 and 0.5Gi). Set workload_profile_name to use a dedicated profile."
    }
  }
}
