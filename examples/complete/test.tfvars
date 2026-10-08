logical_product_family  = "launch"
logical_product_service = "caapp"
class_env               = "dev"
instance_env            = 0
instance_resource       = 0
location                = "eastus2"

resource_names_map = {
  resource_group = {
    name       = "rg"
    max_length = 50
  }
  log_analytics = {
    name       = "law"
    max_length = 63
  }
  container_app_environment = {
    name       = "cae"
    max_length = 32
  }
  container_app = {
    name       = "ca"
    max_length = 32
  }
}

tags = {
  Environment = "test"
  Terraform   = "true"
}
