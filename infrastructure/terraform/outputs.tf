output "s3_bucket_name" {
  value = aws_s3_bucket.files.bucket
}

output "sqs_queue_url" {
  value = aws_sqs_queue.jobs.id
}
