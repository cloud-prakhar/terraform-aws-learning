# The same three queues, created two different ways. SQS queues are used
# because they are created in seconds and cost nothing while idle.

# Version A: count. Instances are identified by POSITION in the list.
#   aws_sqs_queue.by_count[0] = orders
#   aws_sqs_queue.by_count[1] = payments
#   aws_sqs_queue.by_count[2] = emails
resource "aws_sqs_queue" "by_count" {
  count = length(var.queue_names)

  name                    = "count-${var.queue_names[count.index]}"
  sqs_managed_sse_enabled = true
}

# Version B: for_each. Instances are identified by KEY.
#   aws_sqs_queue.by_key["orders"], ["payments"], ["emails"]
# for_each needs a map or a set of strings, so we convert the list.
resource "aws_sqs_queue" "by_key" {
  for_each = toset(var.queue_names)

  name                    = "foreach-${each.value}"
  sqs_managed_sse_enabled = true
}
