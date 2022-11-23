resource "yandex_lb_target_group" "this" {
  name = "${var.name_preffix}-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.this
    content {
      subnet_id = target.value.network_interface.0.subnet_id
      address   = target.value.network_interface.0.ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "this" {
  name = "${var.name_preffix}-lb"

  type = "internal"

  listener {
    name        = "${var.name_preffix}-listener-https"
    port        = 443
    target_port = 443
    internal_address_spec {
      subnet_id = length(var.subnet_ids) == 0 ? yandex_vpc_subnet.this[0].id : var.subnet_ids[0]
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.this.id

    healthcheck {
      name = "https"
      tcp_options {
        port = 443
      }
    }
  }
}
