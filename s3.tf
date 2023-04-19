resource "yandex_iam_service_account" "this" {
    name = "${var.name_preffix}-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "s3editor" {
    role = "storage.editor"
    member = "serviceAccount:${yandex_iam_service_account.this.id}"
    folder_id = yandex_vpc_network.this[0].folder_id
}

resource "yandex_iam_service_account_static_access_key" "this" {
    service_account_id = yandex_iam_service_account.this.id
}

resource "yandex_storage_bucket" "this" {
    access_key = yandex_iam_service_account_static_access_key.this.access_key
    secret_key = yandex_iam_service_account_static_access_key.this.secret_key
    bucket = "${var.name_preffix}-meta-bucket"
}

resource "yandex_storage_object" "this" {
    access_key = yandex_iam_service_account_static_access_key.this.access_key
    secret_key = yandex_iam_service_account_static_access_key.this.secret_key
    bucket = yandex_storage_bucket.this.bucket
    key = "dpinit.sh"
    source = local_file.this.filename
}

locals {
    hosts = zipmap(
        [for lsnr in yandex_lb_network_load_balancer.this: lsnr.listener.*.internal_address_spec[0].*.address[0]],
        [for ep in var.yc_endpoints_struct: ep.endpoint]
    )
}

resource "local_file" "this" {
    content = <<-EOT
#!/bin/bash
%{ for str in [for k, v in local.hosts : "${k} ${v}"] ~}
sudo bash -c "echo '${str}' >> /etc/hosts"
sudo bash -c "echo '${str}' >> /etc/cloud/templates/hosts.debian.tmpl"
%{ endfor }
    EOT
    filename = "dpinit.sh"
}
