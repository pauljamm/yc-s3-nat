data "yandex_compute_image" "this" {
  family = "nat-instance-ubuntu"
}

resource "yandex_compute_instance" "this" {
  count = var.node_count

  name = "${var.name_preffix}-${count.index}"

  resources {
    memory = 2
    cores  = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.this.id
      size     = 10
    }
  }

  network_interface {
    subnet_id = length(var.subnet_ids) == 0 ? yandex_vpc_subnet.this[count.index % length(var.yc_availability_zones)].id : var.subnet_ids[count.index % length(var.subnet_ids)]
    nat       = true
  }

  zone = length(var.subnet_ids) == 0 ? var.yc_availability_zones[count.index % length(var.yc_availability_zones)] : data.yandex_vpc_subnet.this[count.index % length(var.subnet_ids)].zone

  metadata = {
    user-data = templatefile("cloudconfig.yaml", { ssh_public_key = var.ssh_public_key, s3_ip = var.s3_ip })
  }

}
