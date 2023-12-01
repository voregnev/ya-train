resource "yandex_lb_network_load_balancer" "app_lb" {
  name = "nlb"

  listener {
    name = "http"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.app_lb.external_ipv4_address[0].address
    }
  }

  listener {
    name = "https"
    port = 443
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.app_lb.external_ipv4_address[0].address
    }
  }

  listener {
    name = "https-quic"
    protocol = "udp"
    port = 443
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.app_lb.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.app_ig.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/ping"
      }
    }
  }
}
