output "bucket_name" {
  value = alicloud_oss_bucket.this.bucket
}

output "intranet_endpoint" {
  value = alicloud_oss_bucket.this.intranet_endpoint
}

output "extranet_endpoint" {
  value = alicloud_oss_bucket.this.extranet_endpoint
}
