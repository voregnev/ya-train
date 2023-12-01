resource "yandex_vpc_security_group" "app_sg" {
  description = "security group"
  network_id  = module.yc-vpc.vpc_id

  ingress {
    protocol       = "TCP"
    description    = "Allow SSH from home"
    port           = 22
    v4_cidr_blocks = ["176.65.62.144/32"]
  }

  ingress {
    protocol          = "ANY"
    description       = "Communication inside this SG"
    predefined_target = "self_security_group"
  }

  egress {
    protocol          = "ANY"
    description       = "Communication inside this SG"
    predefined_target = "self_security_group"
  }

  ingress {
    protocol          = "TCP"
    description       = "NLB health check"
    predefined_target = "loadbalancer_healthchecks"
    port              = 80
  }

  ingress {
    protocol          = "TCP"
    description       = "NLB health check http3"
    predefined_target = "loadbalancer_healthchecks"
    port              = 81
  }

  ingress {
    protocol       = "TCP"
    description    = "WEB"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "WEB"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "UDP"
    description    = "WEB"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "WEB grafana"
    v4_cidr_blocks = ["176.65.62.144/32"]
    port           = 3000
  }

  # keyserver.ubuntu.com
  egress {
    protocol       = "TCP"
    description    = "To keyserver.ubuntu.com"
    v4_cidr_blocks = ["185.125.188.26/32", "185.125.188.27/32"]
    port           = 11371
  }

  # storage.yandexcloud.net, mirror.yandex.ru
  egress {
    protocol       = "TCP"
    description    = "To s3"
    v4_cidr_blocks = ["213.180.193.243/32", "213.180.204.183/32"]
    port           = 443
  }

  # openresty.org, opm.openresty.org
  egress {
    protocol       = "TCP"
    description    = "To s3"
    v4_cidr_blocks = ["3.125.51.27/32"]
    port           = 443
  }

  # NTP
  egress {
    port           = 123
    protocol       = "UDP"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # hub.docker.com, registry-1.docker.io
  egress {
    port           = 443
    protocol       = "TCP"
    v4_cidr_blocks = ["54.236.113.205/32", "54.227.20.253/32", "54.196.99.49/32", "34.226.69.105/32", "3.219.239.5/32", "104.16.100.207/32", "104.16.101.207/32", "104.16.102.207/32", "104.16.103.207/32", "104.16.104.207/32", "3.216.34.172/32", "44.205.64.79/32", "34.205.13.154/32", "3.228.146.75/32", "18.206.20.10/32", "18.210.197.188/32"]
  }

  egress {
    port           = 80
    protocol       = "TCP"
    v4_cidr_blocks = ["${yandex_vpc_address.app_lb.external_ipv4_address[0].address}/32"]
  }

  # connect to db
  egress {
    protocol       = "TCP"
    description    = "Allow pg connect"
    port           = 6432
    v4_cidr_blocks = module.yc-vpc.private_v4_cidr_blocks
  }
}

resource "yandex_vpc_security_group" "db_sg" {
  description = "db security group"
  network_id  = module.yc-vpc.vpc_id

  ingress {
    protocol       = "TCP"
    description    = "Allow pg connect from app subnet"
    port           = 6432
    v4_cidr_blocks = module.yc-vpc.private_v4_cidr_blocks
  }
  ingress {
    protocol       = "TCP"
    description    = "Allow pg connect from app subnet"
    port           = 6432
    v4_cidr_blocks = module.yc-vpc.public_v4_cidr_blocks
  }
}
