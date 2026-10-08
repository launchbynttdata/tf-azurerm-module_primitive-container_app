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

output "id" {
  description = "Azure resource ID of the Container App."
  value       = module.container_app.id
}

output "name" {
  description = "Name of the Container App."
  value       = module.container_app.name
}

output "resource_group_name" {
  description = "Name of the example resource group."
  value       = module.resource_group.name
}

output "container_app_environment_id" {
  description = "Resource ID of the example Container App Environment."
  value       = module.container_app_environment.id
}

output "location" {
  description = "Azure region of the Container App."
  value       = module.container_app.location
}

output "revision_mode" {
  description = "Revision mode of the Container App."
  value       = module.container_app.revision_mode
}

output "ingress_external_enabled" {
  description = "Whether ingress accepts connections from outside the environment."
  value       = module.container_app.ingress_external_enabled
}

output "container_image" {
  description = "Image of the app container."
  value       = var.template.container[0].image
}

output "identity" {
  description = "Managed identity block on the Container App."
  value       = module.container_app.identity
}
