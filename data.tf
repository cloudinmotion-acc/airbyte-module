# Data sources for partition-agnostic ARN construction and account context
data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
