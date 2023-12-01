resource "yandex_vpc_address" "app_lb" {
  name = "app-lb"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}

resource "yandex_vpc_address" "app_quic" {
  name = "app-lb-quic"
  external_ipv4_address {
    zone_id = "ru-central1-a"
  }
}
