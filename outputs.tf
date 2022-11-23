output "lb_private_ip" {
  value = yandex_lb_network_load_balancer.this.listener.*.internal_address_spec[0].*.address
}
