output "analyzer_sqs_cur_name" {
  value = aws_sqs_queue.analyzer_sqs_queue.name
}

output "scanner_sqs_cur_name" {
  value = aws_sqs_queue.scanner_sqs_queue.name
}
