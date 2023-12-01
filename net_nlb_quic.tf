resource "yandex_lb_network_load_balancer" "app_lb_quic" {
  name = "nlb-quic"

  listener {
    name = "https-quic"
    protocol = "udp"
    port = 443
    external_address_spec {
      ip_version = "ipv4"
      address    = yandex_vpc_address.app_quic.external_ipv4_address[0].address
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.app_ig_http3.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 81
        path = "/ping"
      }
    }
  }
}
