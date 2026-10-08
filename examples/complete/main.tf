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
