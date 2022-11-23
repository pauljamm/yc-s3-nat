variable "node_count" {
  type    = number
  description = "Number of nat vms to create"
  default = 1
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

variable "s3_ip" {
  type        = string
  description = "Yandex Cloud S3 IP address"
  default     = "213.180.193.243"
}

variable "yc_availability_zones" {
  type = list(string)
  default = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-c"
  ]
}

