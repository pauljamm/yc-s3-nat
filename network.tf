resource "yandex_vpc_network" "this" {
  name = "${var.name_preffix}-network"
  count = var.network_id == "" ? 1 : 0
}

resource "yandex_vpc_security_group" "this" {
  name        = "dpnat-sg"
  network_id  = yandex_vpc_network.this[0].id

  ingress {
    protocol = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port = 22
  }

  ingress {
    protocol = "ANY"
    predefined_target = "self_security_group"
    from_port = "0"
    to_port = "65535"
  }

  dynamic "ingress" {
    for_each = var.yc_endpoints_struct
    content {
      protocol = "TCP"
      port = "${ingress.value.port}"
      predefined_target = "loadbalancer_healthchecks"
    }
  }

  dynamic "egress" {
    for_each = var.yc_endpoints_struct
    content {
      protocol = "TCP"
      port = "443"
      v4_cidr_blocks = ["${egress.value.ip}/32"]
    }
  }

  egress {
    protocol = "TCP"
    port = "443"
    v4_cidr_blocks = ["${length(var.subnet_ids) == 0 ? yandex_vpc_subnet.this[0].v4_cidr_blocks[0] : var.subnet_ids[0]}"]
  }

  egress {
    protocol = "ANY"
    predefined_target = "self_security_group"
    from_port = "0"
    to_port = "65535"
  }
}

resource "yandex_vpc_subnet" "this" {
  count = length(var.subnet_ids) == 0 ? length(var.yc_availability_zones) : 0

  name = "${var.name_preffix}-subnet-${element(var.yc_availability_zones, count.index)}"
  zone = element(var.yc_availability_zones, count.index)
  network_id = var.network_id == "" ? yandex_vpc_network.this[0].id : var.network_id
  v4_cidr_blocks = ["10.1${count.index + 1}0.0.0/16"]
}

resource "yandex_vpc_subnet" "that" {
  name = "${var.name_preffix}-subnet-work"
  zone = element(var.yc_availability_zones, 0)
  network_id = var.network_id == "" ? yandex_vpc_network.this[0].id : var.network_id
  v4_cidr_blocks = ["10.0.0.0/16"]
  #route_table_id = yandex_vpc_route_table.this.id
}

data "yandex_vpc_subnet" "this" {
  count = length(var.subnet_ids) != 0 ? length(var.subnet_ids) : 0
  subnet_id = var.subnet_ids[count.index]
}

/*
  # This is simple way, but not currently supported
resource "yandex_vpc_route_table" "this" {
  network_id = var.network_id == "" ? yandex_vpc_network.this[0].id : var.network_id
  name = "${var.name_preffix}-rt"

  dynamic "static_route" {
    for_each = zipmap([for ep in var.yc_endpoints_struct: ep.ip],
      [for lsnr in yandex_lb_network_load_balancer.this: lsnr.listener.*.internal_address_spec[0].*.address[0]]
    )
    content {
      destination_prefix = "${static_route.key}/32"
      next_hop_address = "${static_route.value}"
    }
  }
}
*/