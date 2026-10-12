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

terraform {
  # Sensitive var.secrets in a dynamic for_each needs Terraform 1.10.
  required_version = "~> 1.10"

  required_providers {
    # 4.66 raised the readiness probe failure_count_threshold limit to 48 and
    # the startup probe limit to 240 (4.65 caps both at 30); the probe
    # validations here allow those values.
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.66"
    }
  }
}
