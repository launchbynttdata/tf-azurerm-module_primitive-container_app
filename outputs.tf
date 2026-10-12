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
  value       = azurerm_container_app.container_app.id
}

output "name" {
  description = "Name of the Container App."
  value       = azurerm_container_app.container_app.name
}

output "resource_group_name" {
  description = "Resource group of the Container App."
  value       = azurerm_container_app.container_app.resource_group_name
}

output "container_app_environment_id" {
  description = "Resource ID of the Container App Environment."
  value       = azurerm_container_app.container_app.container_app_environment_id
}

output "revision_mode" {
  description = "Revision mode of the Container App."
  value       = azurerm_container_app.container_app.revision_mode
}

output "location" {
  description = "Azure region of the Container App. This is the same region as the Container App Environment."
  value       = azurerm_container_app.container_app.location
}

output "custom_domain_verification_id" {
  description = "Custom domain verification ID of the Container App."
  value       = azurerm_container_app.container_app.custom_domain_verification_id
  sensitive   = true
}

output "latest_revision_fqdn" {
  description = "FQDN of the latest revision."
  value       = azurerm_container_app.container_app.latest_revision_fqdn
}

output "latest_revision_name" {
  description = "Name of the latest revision."
  value       = azurerm_container_app.container_app.latest_revision_name
}

output "outbound_ip_addresses" {
  description = "Public IP addresses the Container App uses for outbound traffic."
  value       = azurerm_container_app.container_app.outbound_ip_addresses
}

output "ingress_fqdn" {
  description = "FQDN of the ingress. Null when ingress is not configured."
  value       = try(azurerm_container_app.container_app.ingress[0].fqdn, null)
}

output "ingress_external_enabled" {
  description = "Whether ingress accepts connections from outside the Container App Environment. Null when ingress is not configured."
  value       = try(azurerm_container_app.container_app.ingress[0].external_enabled, null)
}

output "identity" {
  description = "Managed identity block on the Container App. identity_ids is an empty list when the app has no user-assigned identities."
  value = [
    for id in azurerm_container_app.container_app.identity : merge(id, {
      identity_ids = id.identity_ids == null ? [] : id.identity_ids
    })
  ]
}

output "workload_profile_name" {
  description = "Workload profile used by the Container App."
  value       = azurerm_container_app.container_app.workload_profile_name
}

output "max_inactive_revisions" {
  description = "Maximum number of inactive revisions kept for this Container App."
  value       = azurerm_container_app.container_app.max_inactive_revisions
}

output "tags" {
  description = "Tags assigned to the Container App."
  value       = azurerm_container_app.container_app.tags
}
