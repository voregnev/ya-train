resource "yandex_iam_service_account" "ig_sa" {
  name        = "ig-sa"
  description = "service account to manage IG"
}

resource "yandex_resourcemanager_folder_iam_member" "ig_sa_permission" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

resource "yandex_compute_instance_group" "app_ig" {
  name                = "app-instance-group"
  folder_id           = var.folder_id
  service_account_id  = yandex_iam_service_account.ig_sa.id
  deletion_protection = false

  instance_template {
    platform_id = "standard-v3"
    resources {
      memory        = 4
      cores         = 2
      core_fraction = 50
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        type     = "network-ssd"
        image_id = var.image_id_ubuntu_2204
      }
    }

    network_interface {
      network_id         = module.yc-vpc.vpc_id
      subnet_ids         = [module.yc-vpc.private_subnets["10.10.10.0/24"].subnet_id]
      security_group_ids = [yandex_vpc_security_group.app_sg.id]
    }

    metadata = {
      user-data = templatefile("cloud-config.yaml", {
        db_id   = module.yc-db.cluster_id
        db_user = var.db_user
        db_pass = module.yc-db.users_data[0].password
        db_name = var.db_name
        ext_ip  = yandex_vpc_address.app_lb.external_ipv4_address[0].address
      })
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 2
  }

  load_balancer {
    target_group_name        = "app-target-gr"
    target_group_description = "load balancer target group"
  }

  depends_on = [yandex_resourcemanager_folder_iam_member.ig_sa_permission]
}
