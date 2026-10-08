# tf-azurerm-module_primitive-container_app

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This Terraform primitive manages one Azure Container App (`azurerm_container_app`). It wraps a single app: revision mode, template containers, ingress, identity, registries, and secrets. The Container App Environment, Log Analytics workspace, and resource group belong in the calling stack.

The provider constraint is azurerm `~> 4.68`, matching `module_primitive/container_app_environment` 2.0.5.

## Usage

See the [complete example](examples/complete/) for a Consumption environment, a system-assigned identity, and ingress that stays inside the environment.

```hcl
module "container_app" {
  source = "../.."

  name                         = lower(module.resource_names["container_app"].minimal_random_suffix)
  resource_group_name          = module.resource_group.name
  container_app_environment_id = module.container_app_environment.id
  revision_mode                = var.revision_mode
  workload_profile_name        = var.workload_profile_name

  template               = var.template
  ingress                = var.ingress
  identity               = var.identity
  registries             = var.registries
  secrets                = var.secrets
  dapr                   = var.dapr
  max_inactive_revisions = var.max_inactive_revisions
  tags                   = var.tags

  depends_on = [module.container_app_environment]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.68 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.container_app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | Resource ID of the Container App Environment. Changing this forces a new resource. | `string` | n/a | yes |
| <a name="input_dapr"></a> [dapr](#input\_dapr) | Dapr sidecar. app\_protocol is http or grpc. | <pre>object({<br/>    app_id       = string<br/>    app_port     = optional(number)<br/>    app_protocol = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity. type is SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None. identity\_ids is required for UserAssigned and SystemAssigned, UserAssigned. | <pre>object({<br/>    type         = string<br/>    identity_ids = optional(list(string), [])<br/>  })</pre> | `null` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress for the app. external\_enabled defaults to false in the provider when omitted here. traffic\_weight percentages must sum to 100. exposed\_port is only valid when transport is tcp. When a Key Vault certificate hostname is required, use azurerm\_container\_app\_custom\_domain; ingress.custom\_domain is computed in azurerm 4.x and is not an input. | <pre>object({<br/>    allow_insecure_connections = optional(bool)<br/>    external_enabled           = optional(bool)<br/>    target_port                = number<br/>    exposed_port               = optional(number)<br/>    transport                  = optional(string)<br/>    client_certificate_mode    = optional(string)<br/>    traffic_weight = list(object({<br/>      label           = optional(string)<br/>      latest_revision = optional(bool, false)<br/>      percentage      = number<br/>      revision_suffix = optional(string)<br/>    }))<br/>    ip_security_restriction = optional(list(object({<br/>      action           = string<br/>      description      = optional(string)<br/>      ip_address_range = string<br/>      name             = string<br/>    })), [])<br/>    cors = optional(object({<br/>      allowed_origins           = list(string)<br/>      allow_credentials_enabled = optional(bool)<br/>      allowed_headers           = optional(list(string), [])<br/>      allowed_methods           = optional(list(string), [])<br/>      exposed_headers           = optional(list(string), [])<br/>      max_age_in_seconds        = optional(number)<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_max_inactive_revisions"></a> [max\_inactive\_revisions](#input\_max\_inactive\_revisions) | Maximum number of inactive revisions kept for this Container App. | `number` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the Container App. Must be 2-32 lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character. Changing this forces a new resource. | `string` | n/a | yes |
| <a name="input_registries"></a> [registries](#input\_registries) | Container registries. Each entry uses either identity or username plus password\_secret\_name. | <pre>list(object({<br/>    server               = string<br/>    identity             = optional(string)<br/>    username             = optional(string)<br/>    password_secret_name = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group containing the Container App Environment. Changing this forces a new resource. | `string` | n/a | yes |
| <a name="input_revision_mode"></a> [revision\_mode](#input\_revision\_mode) | Revision mode. Single keeps one active revision. Multiple allows more than one, with traffic split in ingress.traffic\_weight. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets available to the app. Set value for a literal secret, or key\_vault\_secret\_id together with identity (a user-assigned identity resource ID, or System). Do not set both value and key\_vault\_secret\_id. When key\_vault\_secret\_id is used, the provider ignores value and recommends that the caller ignore changes to value. | <pre>list(object({<br/>    name                = string<br/>    value               = optional(string)<br/>    key_vault_secret_id = optional(string)<br/>    identity            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags assigned to the Container App. | `map(string)` | `{}` | no |
| <a name="input_template"></a> [template](#input\_template) | App template. container is one or more containers. On Consumption, cpu and memory must be a documented pair such as 0.25 and 0.5Gi. Init containers, scale rules, and volumes are optional. | <pre>object({<br/>    container = list(object({<br/>      name    = string<br/>      image   = string<br/>      cpu     = number<br/>      memory  = string<br/>      command = optional(list(string))<br/>      args    = optional(list(string))<br/>      env = optional(list(object({<br/>        name        = string<br/>        value       = optional(string)<br/>        secret_name = optional(string)<br/>      })), [])<br/>      liveness_probe = optional(object({<br/>        transport               = string<br/>        port                    = number<br/>        host                    = optional(string)<br/>        path                    = optional(string)<br/>        initial_delay           = optional(number)<br/>        interval_seconds        = optional(number)<br/>        timeout                 = optional(number)<br/>        failure_count_threshold = optional(number)<br/>        header = optional(list(object({<br/>          name  = string<br/>          value = string<br/>        })), [])<br/>      }))<br/>      readiness_probe = optional(object({<br/>        transport               = string<br/>        port                    = number<br/>        host                    = optional(string)<br/>        path                    = optional(string)<br/>        interval_seconds        = optional(number)<br/>        timeout                 = optional(number)<br/>        failure_count_threshold = optional(number)<br/>        success_count_threshold = optional(number)<br/>        header = optional(list(object({<br/>          name  = string<br/>          value = string<br/>        })), [])<br/>      }))<br/>      startup_probe = optional(object({<br/>        transport               = string<br/>        port                    = number<br/>        host                    = optional(string)<br/>        path                    = optional(string)<br/>        initial_delay           = optional(number)<br/>        interval_seconds        = optional(number)<br/>        timeout                 = optional(number)<br/>        failure_count_threshold = optional(number)<br/>        header = optional(list(object({<br/>          name  = string<br/>          value = string<br/>        })), [])<br/>      }))<br/>      volume_mounts = optional(list(object({<br/>        name     = string<br/>        path     = string<br/>        sub_path = optional(string)<br/>      })), [])<br/>    }))<br/>    init_container = optional(list(object({<br/>      name    = string<br/>      image   = string<br/>      cpu     = optional(number)<br/>      memory  = optional(string)<br/>      command = optional(list(string))<br/>      args    = optional(list(string))<br/>      env = optional(list(object({<br/>        name        = string<br/>        value       = optional(string)<br/>        secret_name = optional(string)<br/>      })), [])<br/>      volume_mounts = optional(list(object({<br/>        name     = string<br/>        path     = string<br/>        sub_path = optional(string)<br/>      })), [])<br/>    })), [])<br/>    min_replicas                     = optional(number)<br/>    max_replicas                     = optional(number)<br/>    cooldown_period_in_seconds       = optional(number)<br/>    polling_interval_in_seconds      = optional(number)<br/>    termination_grace_period_seconds = optional(number)<br/>    revision_suffix                  = optional(string)<br/>    azure_queue_scale_rule = optional(list(object({<br/>      name         = string<br/>      queue_name   = string<br/>      queue_length = number<br/>      authentication = list(object({<br/>        secret_name       = string<br/>        trigger_parameter = string<br/>      }))<br/>    })), [])<br/>    custom_scale_rule = optional(list(object({<br/>      name             = string<br/>      custom_rule_type = string<br/>      metadata         = map(string)<br/>      authentication = optional(list(object({<br/>        secret_name       = string<br/>        trigger_parameter = string<br/>      })), [])<br/>    })), [])<br/>    http_scale_rule = optional(list(object({<br/>      name                = string<br/>      concurrent_requests = number<br/>      authentication = optional(list(object({<br/>        secret_name       = string<br/>        trigger_parameter = string<br/>      })), [])<br/>    })), [])<br/>    tcp_scale_rule = optional(list(object({<br/>      name                = string<br/>      concurrent_requests = number<br/>      authentication = optional(list(object({<br/>        secret_name       = string<br/>        trigger_parameter = string<br/>      })), [])<br/>    })), [])<br/>    volume = optional(list(object({<br/>      name          = string<br/>      storage_name  = optional(string)<br/>      storage_type  = optional(string)<br/>      mount_options = optional(string)<br/>    })), [])<br/>  })</pre> | n/a | yes |
| <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name) | Workload profile in the Container App Environment. Null uses the environment default (Consumption on a Consumption environment). Dedicated profiles are not limited to the Consumption CPU and memory pairs. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | Resource ID of the Container App Environment. |
| <a name="output_custom_domain_verification_id"></a> [custom\_domain\_verification\_id](#output\_custom\_domain\_verification\_id) | Custom domain verification ID of the Container App. |
| <a name="output_id"></a> [id](#output\_id) | Azure resource ID of the Container App. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity block on the Container App. identity\_ids is an empty list when the app has no user-assigned identities. |
| <a name="output_ingress_external_enabled"></a> [ingress\_external\_enabled](#output\_ingress\_external\_enabled) | Whether ingress accepts connections from outside the Container App Environment. Null when ingress is not configured. |
| <a name="output_ingress_fqdn"></a> [ingress\_fqdn](#output\_ingress\_fqdn) | FQDN of the ingress. Null when ingress is not configured. |
| <a name="output_latest_revision_fqdn"></a> [latest\_revision\_fqdn](#output\_latest\_revision\_fqdn) | FQDN of the latest revision. |
| <a name="output_latest_revision_name"></a> [latest\_revision\_name](#output\_latest\_revision\_name) | Name of the latest revision. |
| <a name="output_location"></a> [location](#output\_location) | Azure region of the Container App. This is the same region as the Container App Environment. |
| <a name="output_max_inactive_revisions"></a> [max\_inactive\_revisions](#output\_max\_inactive\_revisions) | Maximum number of inactive revisions kept for this Container App. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Container App. |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Public IP addresses the Container App uses for outbound traffic. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group of the Container App. |
| <a name="output_revision_mode"></a> [revision\_mode](#output\_revision\_mode) | Revision mode of the Container App. |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags assigned to the Container App. |
| <a name="output_workload_profile_name"></a> [workload\_profile\_name](#output\_workload\_profile\_name) | Workload profile used by the Container App. |
<!-- END_TF_DOCS -->

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain pre-commit hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run the `make configure` command.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider (e.g. AWS or Azure) for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default (main) branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge. A breaking change will trigger a major version bump, a feature will trigger a minor version bump, and all other types will trigger a patch version bump.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules (e.g. Lambda functions), there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
