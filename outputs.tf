output "dp_init_script" {
  description = "Use this S3 object as init script for ypur Data Proc clusters"
  value = "s3a://${yandex_storage_bucket.this.bucket}/${yandex_storage_object.this.key}"
}