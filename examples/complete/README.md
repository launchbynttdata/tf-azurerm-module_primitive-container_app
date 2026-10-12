# complete

Deploys one Container App on a Consumption environment. Ingress stays inside the environment (`external_enabled = false`) and the app uses a system-assigned identity. The image is the public quickstart, `mcr.microsoft.com/k8se/quickstart:latest`, with the Consumption pair 0.25 vCPU and 0.5Gi.

```hcl
module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  region                  = var.location
  class_env               = var.class_env
  cloud_resource_type     = each.value.name
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  maximum_length          = each.value.max_length
  use_azure_region_abbr   = true
}

module "resource_group" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm"
  version = "~> 2.0"

  name     = module.resource_names["resource_group"].minimal_random_suffix
  location = var.location

  tags = merge(var.tags, {
    resource_name = module.resource_names["resource_group"].standard
  })
}

module "log_analytics_workspace" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm"
  version = "~> 2.0"

  name                = module.resource_names["log_analytics"].minimal_random_suffix
  location            = var.location
  resource_group_name = module.resource_group.name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_in_days

  tags = merge(var.tags, {
    resource_name = module.resource_names["log_analytics"].standard
  })

  # module.resource_group.name is the input string, so it does not order this
  # module after the group is created (tf-azurerm-module_primitive-resource_group#37).
  # Remove once #38 is released and this example resolves that version.
  depends_on = [module.resource_group]
}

module "container_app_environment" {
  source  = "terraform.registry.launch.nttdata.com/module_primitive/container_app_environment/azurerm"
  version = "~> 2.0"

  name                       = lower(module.resource_names["container_app_environment"].minimal_random_suffix)
  location                   = var.location
  resource_group_name        = module.resource_group.name
  log_analytics_workspace_id = module.log_analytics_workspace.id

  tags = merge(var.tags, {
    resource_name = module.resource_names["container_app_environment"].standard
  })
}

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_container_app"></a> [container\_app](#module\_container\_app) | ../.. | n/a |
| <a name="module_container_app_environment"></a> [container\_app\_environment](#module\_container\_app\_environment) | terraform.registry.launch.nttdata.com/module_primitive/container_app_environment/azurerm | ~> 2.0 |
| <a name="module_log_analytics_workspace"></a> [log\_analytics\_workspace](#module\_log\_analytics\_workspace) | terraform.registry.launch.nttdata.com/module_primitive/log_analytics_workspace/azurerm | ~> 2.0 |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform.registry.launch.nttdata.com/module_primitive/resource_group/azurerm | ~> 2.0 |
| <a name="module_resource_names"></a> [resource\_names](#module\_resource\_names) | terraform.registry.launch.nttdata.com/module_library/resource_name/launch | ~> 2.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_class_env"></a> [class\_env](#input\_class\_env) | Environment class used for resource naming. | `string` | `"dev"` | no |
| <a name="input_dapr"></a> [dapr](#input\_dapr) | Dapr sidecar passed to the Container App. | <pre>object({<br/>    app_id       = string<br/>    app_port     = optional(number)<br/>    app_protocol = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Managed identity passed to the Container App. | <pre>object({<br/>    type = string<br/>  })</pre> | <pre>{<br/>  "type": "SystemAssigned"<br/>}</pre> | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Ingress passed to the Container App. external\_enabled is false so the app is reachable only inside the environment. | <pre>object({<br/>    external_enabled = bool<br/>    target_port      = number<br/>    transport        = string<br/>    traffic_weight = list(object({<br/>      latest_revision = bool<br/>      percentage      = number<br/>    }))<br/>  })</pre> | <pre>{<br/>  "external_enabled": false,<br/>  "target_port": 80,<br/>  "traffic_weight": [<br/>    {<br/>      "latest_revision": true,<br/>      "percentage": 100<br/>    }<br/>  ],<br/>  "transport": "auto"<br/>}</pre> | no |
| <a name="input_instance_env"></a> [instance\_env](#input\_instance\_env) | Numeric environment instance used for resource naming. | `number` | `0` | no |
| <a name="input_instance_resource"></a> [instance\_resource](#input\_instance\_resource) | Numeric resource instance used for resource naming. | `number` | `0` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which to deploy the example. | `string` | `"eastus2"` | no |
| <a name="input_log_analytics_retention_in_days"></a> [log\_analytics\_retention\_in\_days](#input\_log\_analytics\_retention\_in\_days) | Log Analytics retention in days. | `number` | `30` | no |
| <a name="input_log_analytics_sku"></a> [log\_analytics\_sku](#input\_log\_analytics\_sku) | SKU of the Log Analytics workspace used by the Container App Environment. | `string` | `"PerGB2018"` | no |
| <a name="input_logical_product_family"></a> [logical\_product\_family](#input\_logical\_product\_family) | Logical product family used for resource naming. | `string` | `"launch"` | no |
| <a name="input_logical_product_service"></a> [logical\_product\_service](#input\_logical\_product\_service) | Logical product service used for resource naming. | `string` | `"caapp"` | no |
| <a name="input_max_inactive_revisions"></a> [max\_inactive\_revisions](#input\_max\_inactive\_revisions) | Maximum inactive revisions passed to the Container App. | `number` | `null` | no |
| <a name="input_registries"></a> [registries](#input\_registries) | Container registries passed to the Container App. | <pre>list(object({<br/>    server               = string<br/>    identity             = optional(string)<br/>    username             = optional(string)<br/>    password_secret_name = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_resource_names_map"></a> [resource\_names\_map](#input\_resource\_names\_map) | Map of resource naming keys to cloud abbreviations and maximum lengths. | <pre>map(object({<br/>    name       = string<br/>    max_length = number<br/>  }))</pre> | n/a | yes |
| <a name="input_revision_mode"></a> [revision\_mode](#input\_revision\_mode) | Revision mode passed to the Container App. | `string` | `"Single"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets passed to the Container App. | <pre>list(object({<br/>    name                = string<br/>    value               = optional(string)<br/>    key_vault_secret_id = optional(string)<br/>    identity            = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to example resources that support tags. | `map(string)` | `{}` | no |
| <a name="input_template"></a> [template](#input\_template) | Container template passed to the Container App. Probes set only transport and port so the provider defaults apply. | <pre>object({<br/>    container = list(object({<br/>      name   = string<br/>      image  = string<br/>      cpu    = number<br/>      memory = string<br/>      liveness_probe = object({<br/>        transport = string<br/>        port      = number<br/>      })<br/>      readiness_probe = object({<br/>        transport = string<br/>        port      = number<br/>      })<br/>      startup_probe = object({<br/>        transport = string<br/>        port      = number<br/>      })<br/>    }))<br/>  })</pre> | <pre>{<br/>  "container": [<br/>    {<br/>      "cpu": 0.25,<br/>      "image": "mcr.microsoft.com/k8se/quickstart:latest",<br/>      "liveness_probe": {<br/>        "port": 80,<br/>        "transport": "HTTP"<br/>      },<br/>      "memory": "0.5Gi",<br/>      "name": "app",<br/>      "readiness_probe": {<br/>        "port": 80,<br/>        "transport": "HTTP"<br/>      },<br/>      "startup_probe": {<br/>        "port": 80,<br/>        "transport": "TCP"<br/>      }<br/>    }<br/>  ]<br/>}</pre> | no |
| <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name) | Workload profile passed to the Container App. Null uses Consumption. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | Resource ID of the example Container App Environment. |
| <a name="output_container_image"></a> [container\_image](#output\_container\_image) | Image of the app container. |
| <a name="output_id"></a> [id](#output\_id) | Azure resource ID of the Container App. |
| <a name="output_identity"></a> [identity](#output\_identity) | Managed identity block on the Container App. identity\_ids is an empty list when the app has no user-assigned identities. |
| <a name="output_ingress_external_enabled"></a> [ingress\_external\_enabled](#output\_ingress\_external\_enabled) | Whether ingress accepts connections from outside the environment. |
| <a name="output_location"></a> [location](#output\_location) | Azure region of the Container App. |
| <a name="output_name"></a> [name](#output\_name) | Name of the Container App. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the example resource group. |
| <a name="output_revision_mode"></a> [revision\_mode](#output\_revision\_mode) | Revision mode of the Container App. |
<!-- END_TF_DOCS -->
