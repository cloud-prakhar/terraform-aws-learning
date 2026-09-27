# Deliberately small: two cheap resources give you something to inspect
# with `terraform state list/show` and to refactor with `moved` blocks.

resource "aws_sqs_queue" "orders" {
  name                    = "tf-learning-state-orders"
  sqs_managed_sse_enabled = true
}

resource "aws_s3_bucket" "uploads" {
  bucket_prefix = "tf-learning-state-uploads-"
  force_destroy = true
}

# --- Exercise 2 (see README) -----------------------------------------
# Rename aws_sqs_queue.orders to aws_sqs_queue.order_events, then
# uncomment this block. Terraform will MOVE the state entry instead of
# destroying and recreating the queue.
#
# moved {
#   from = aws_sqs_queue.orders
#   to   = aws_sqs_queue.order_events
# }
