variable "node_count" {
  type    = number
  description = "Number of nat vms to create"
  default = 3
}

variable "node_cores" {
  type = number
  description = "CPU count for NAT nodes"
  default = 2
}

variable "node_ram" {
  type = number
  description = "RAM ammount for NAT nodes"
  default = 4
}

variable "name_preffix" {
  type        = string
  description = "Name preffix for created objects"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key to add to vms"
}

variable "network_id" {
  type        = string
  description = "Network ID where nat vms should be created. Default create new network"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where nat vms should be created. Default create new subnets, one in every az"
  default     = []
}

variable "yc_availability_zones" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}

# endpoint and unique custom target group port to be used
variable "yc_endpoints_struct" {
  type = list(map(string))
  default = [
    {
      name = "storage"
      ip = "213.180.193.243"
      port = "8001"
      endpoint = "storage.yandexcloud.net"
      },
    {
      name = "monitoring"
      ip = "158.160.59.216"#"213.180.193.8"
      port = "8002"
      endpoint = "monitoring.api.cloud.yandex.net"
      },
    {
      name = "api"
      ip = "84.201.181.26"
      port = "8003"
      endpoint = "api.cloud.yandex.net  dataproc-ui.yandexcloud.net dataproc-manager.api.cloud.yandex.net"
      },
    {
      name = "logging"
      ip = "84.201.181.184"
      port = "8004"
      endpoint = "ingester.logging.yandexcloud.net"
    }
  ]
}