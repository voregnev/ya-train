provider "yandex" {
  zone      = "ru-central1-a"
  folder_id = var.folder_id
  cloud_id  = var.cloud_id
}

terraform {
  required_version = ">=1.1.0"
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "=0.92.0"
    }
  }
}
