# Add metric filter

resource "aws_cloudwatch_log_metric_filter" "info_count" {
  name           = "info-count"
  log_group_name = aws_cloudwatch_log_group.http_api.name
  pattern        = "\"INFO\""

  metric_transformation {
    name      = "info-count"
    namespace = "/moviesdb-api/${local.name_prefix}"
    value     = "1"
    unit      = "None"
  }
}
#Create Alarm
resource "aws_cloudwatch_metric_alarm" "info_count_alarm" {
  alarm_name          = "${local.name_prefix}-info-count-breach"
  alarm_description   = "Alarm when INFO count exceeds 10 per minute"
  namespace           = "/moviesdb-api/${local.name_prefix}"
  metric_name         = "info-count"
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  datapoints_to_alarm = 1
  unit                = "None"
  alarm_actions = [aws_sns_topic.alarm_notifications.arn]
  ok_actions = [aws_sns_topic.alarm_notifications.arn]
}

#create SNS topic
resource "aws_sns_topic" "alarm_notifications" {
  name = "${local.name_prefix}-alarm-topic"
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.alarm_notifications.arn
  protocol  = "email"
  endpoint  = "rbs.ramya@gmail.com"  
}
