resource "aws_cloudwatch_log_group" "aws_route53_query_log" {
  provider = aws.us-east-1 # Route53 query logging must be in us-east-1 https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_query_log

  name              = "/aws/route53/${local.csi}"
  retention_in_days = var.log_retention_in_days
}

resource "aws_cloudwatch_log_resource_policy" "route53_query_logging_policy" {
  provider = aws.us-east-1 # Route53 query logging must be in us-east-1 https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_query_log

  policy_document = data.aws_iam_policy_document.route53_logs.json
  policy_name     = "${local.csi}-route53-query-logging-policy"
}

data "aws_iam_policy_document" "route53_logs" {
  statement {
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "route53.amazonaws.com"
      ]
    }

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_cloudwatch_log_group.aws_route53_query_log.arn,
      "${aws_cloudwatch_log_group.aws_route53_query_log.arn}:*",
    ]
  }
}
