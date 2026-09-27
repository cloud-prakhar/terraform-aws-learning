resource "aws_sqs_queue" "jobs" {
  name                    = "tf-learning-remote-state-jobs"
  sqs_managed_sse_enabled = true
}
