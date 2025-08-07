output "scrapper_bucket_name" {
  value = aws_s3_bucket.scrapper_bucket.bucket
}

output "layers_bucket_key" {
  value = aws_s3_object.scrapper_layers.key
}

output "handler_bucket_key" {
  value = aws_s3_object.scrapper_handler.key
}
