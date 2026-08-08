terraform {
  required_version = ">= 1.8.0, < 2.0.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.285.0"
    }
  }
}
