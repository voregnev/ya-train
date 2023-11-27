resource "yandex_compute_instance" "sandbox_sec" {
  name        = "sandbox-sec"
  hostname    = "sandbox-sec"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"
  resources {
    cores         = 2
    memory        = 8
    core_fraction = 50
  }
  boot_disk {
    initialize_params {
      type     = "network-ssd"
      image_id = var.image_id_ubuntu_2204
      size     = 64
    }
  }

  network_interface {
    subnet_id = module.yc-vpc.public_subnets["10.10.0.0/24"].subnet_id
    nat       = true
    security_group_ids = [yandex_vpc_security_group.app_sg.id]
  }

  metadata = {
    user-data = file("cloud-config.yaml")
  }

  scheduling_policy {
    preemptible = false
  }

  lifecycle {
    ignore_changes = [
      metadata,
    ]
  }
}
