resource "aws_s3_bucket" "files" {
  bucket = "${var.project_name}-files"
}

