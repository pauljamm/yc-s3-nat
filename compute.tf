data "yandex_compute_image" "this" {
  family = "nat-instance-ubuntu"
}

resource "yandex_compute_instance" "this" {
  count = var.node_count

  platform_id = "standard-v3"
  name = "${var.name_preffix}-${count.index}"

  resources {
    memory = var.node_ram
    cores  = var.node_cores
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.this.id
      size     = 100
    }
  }

  network_interface {
    subnet_id = length(var.subnet_ids) == 0 ? yandex_vpc_subnet.this[count.index % length(var.yc_availability_zones)].id : var.subnet_ids[count.index % length(var.subnet_ids)]
    nat       = true
    security_group_ids = [ yandex_vpc_security_group.this.id ]
  }

  zone = length(var.subnet_ids) == 0 ? var.yc_availability_zones[count.index % length(var.yc_availability_zones)] : data.yandex_vpc_subnet.this[count.index % length(var.subnet_ids)].zone

  metadata = {
    user-data = templatefile("cloudconfig.yaml", { ssh_public_key = var.ssh_public_key, endpoints = var.yc_endpoints_struct })
  }
  
}
