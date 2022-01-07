resource "aws_wafv2_web_acl" "fizzbuzz" {
  name        = "fizzbuzz-api-waf-rules"
  description = "Implement AWS WAR rules for FizzBuzz API"
  scope       = "REGIONAL"

  default_action {
    # pass traffic until the rules trigger a block
    allow {}
  }

  rule {
    name     = "rate-limit-500-per-5"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        # Amount of request allowed per 5 minutes
        limit              = 500
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "rate-limit-500-per-5-minutes"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "fizzbuzz-waf-rules"
    sampled_requests_enabled   = false
  }
}