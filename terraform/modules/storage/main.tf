resource "alicloud_oss_bucket" "this" {
  bucket        = var.bucket_name
  storage_class = "Standard"
  tags          = var.tags

  lifecycle_rule {
    id      = "abort-incomplete-multipart-uploads"
    prefix  = ""
    enabled = true

    abort_multipart_upload {
      days = 7
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      server_side_encryption_rule,
      versioning,
    ]
  }
}

resource "alicloud_oss_bucket_acl" "this" {
  bucket = alicloud_oss_bucket.this.bucket
  acl    = "private"
}

resource "alicloud_oss_bucket_versioning" "this" {
  bucket = alicloud_oss_bucket.this.bucket
  status = "Enabled"
}

resource "alicloud_oss_bucket_server_side_encryption" "this" {
  bucket        = alicloud_oss_bucket.this.bucket
  sse_algorithm = "AES256"
}
