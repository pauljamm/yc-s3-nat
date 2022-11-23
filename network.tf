resource "yandex_vpc_network" "this" {
  name  = "${var.name_preffix}-network"
  count = var.network_id == "" ? 1 : 0
}

resource "yandex_vpc_subnet" "this" {
  count = length(var.subnet_ids) == 0 ? length(var.yc_availability_zones) : 0

  name           = "${var.name_preffix}-subnet-${element(var.yc_availability_zones, count.index)}"
  zone           = element(var.yc_availability_zones, count.index)
  network_id     = var.network_id == "" ? yandex_vpc_network.this[0].id : var.network_id
  v4_cidr_blocks = ["10.1${count.index + 1}0.0.0/16"]
}

data "yandex_vpc_subnet" "this" {
  count = length(var.subnet_ids) != 0 ? length(var.subnet_ids) : 0
  subnet_id = var.subnet_ids[count.index]
}