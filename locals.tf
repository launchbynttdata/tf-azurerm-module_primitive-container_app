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

locals {
  # Consumption vCPU/memory pairs from the azurerm 3.117 container schema.
  consumption_pairs = [
    { cpu = 0.25, memory = ["0.5Gi"] },
    { cpu = 0.5, memory = ["1Gi", "1.0Gi"] },
    { cpu = 0.75, memory = ["1.5Gi"] },
    { cpu = 1, memory = ["2Gi", "2.0Gi"] },
    { cpu = 1.25, memory = ["2.5Gi"] },
    { cpu = 1.5, memory = ["3Gi", "3.0Gi"] },
    { cpu = 1.75, memory = ["3.5Gi"] },
    { cpu = 2, memory = ["4Gi", "4.0Gi"] },
  ]

  consumption_containers = concat(
    [for container in var.template.container : { cpu = container.cpu, memory = container.memory }],
    [for container in var.template.init_container : { cpu = container.cpu, memory = container.memory } if container.cpu != null && container.memory != null],
  )
}
