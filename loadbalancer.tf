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
  count = length(var.yc_endpoints_struct)
  name = "${var.name_preffix}-lb-${var.yc_endpoints_struct[count.index].name}"

  type = "internal"

  listener {
    name = "${var.name_preffix}-lsnr-${var.yc_endpoints_struct[count.index].name}"
    port = "443"
    target_port = var.yc_endpoints_struct[count.index].port

    internal_address_spec {
      subnet_id = length(var.subnet_ids) == 0 ? yandex_vpc_subnet.this[0].id : var.subnet_ids[0]
    }
  }
 
  # Those operations become blocked on target group object if it is the same for all balancers. Using GRPC API in local_exec instead.
  /*
  attached_target_group {
    target_group_id = yandex_lb_target_group.this.id

    healthcheck {
      name = "custom"
      interval = 300
      timeout = 10
      unhealthy_threshold = 1
      healthy_threshold = 1
      tcp_options {
        port = var.yc_endpoints_struct[count.index].port
      }
    }
  }
*/

  provisioner "local-exec" {
    command = <<-CMD
    sleep ${count.index * 30} && curl -s -d '{ attachedTargetGroup: { targetGroupId: "${yandex_lb_target_group.this.id}", healthChecks: [{ name: "custom", interval: "30s", timeout: "10s", unhealthyThreshold: 2, healthyThreshold: 2, tcpOptions: {port: ${var.yc_endpoints_struct[count.index].port}} }] }}' -H "Authorization: Bearer $YC_TOKEN" -X POST https://load-balancer.api.cloud.yandex.net/load-balancer/v1/networkLoadBalancers/${self.id}:attachTargetGroup
    CMD
  }
}
