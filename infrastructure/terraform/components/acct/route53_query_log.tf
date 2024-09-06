resource "aws_route53_query_log" "main" {
  zone_id = aws_route53_zone.main.zone_id

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.aws_route53_query_log.arn

  depends_on = [
    aws_cloudwatch_log_resource_policy.route53_query_logging_policy
  ]
}
