terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1" # Ireland – samme som appen
}

resource "aws_sns_topic" "sentiment_alerts" {
  name = "kandidat70-sentiment-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.sentiment_alerts.arn
  protocol  = "email"
  endpoint  = "maas034@student.kristiania.no"
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "kandidat70-high-latency"
  alarm_description   = "Sentiment analysis latency over 5 seconds"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  threshold           = 100000              
  metric_name         = "sentiment.analysis.duration"
  namespace           = "kandidat70"
  period              = 60                    
  statistic           = "Average"
  treat_missing_data  = "breaching"

  dimensions = {
    company = "Apple"
    model   = "AI-Powered (AWS Bedrock + Claude)"
  }

  alarm_actions = [
    aws_sns_topic.sentiment_alerts.arn
  ]
}

resource "aws_cloudwatch_dashboard" "sentiment_dashboard" {
  dashboard_name = "kandidat70-sentiment-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type" : "metric",
        "x" : 0,
        "y" : 0,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Total sentiment analyses (Apple, POSITIVE)",
          "view" : "timeSeries",
          "region" : "eu-west-1",
          "stat" : "Sum",
          "metrics" : [
            # [ Namespace, MetricName, DimName1, DimVal1, DimName2, DimVal2, {...opts} ]
            ["kandidat70", "sentiment.analysis.total", "company", "Apple", "sentiment", "POSITIVE"]
          ]
        }
      },

      {
        "type" : "metric",
        "x" : 0,
        "y" : 6,
        "width" : 12,
        "height" : 6,
        "properties" : {
          "title" : "Sentiment analysis duration (Apple)",
          "view" : "timeSeries",
          "region" : "eu-west-1",
          "stat" : "Average",
          "metrics" : [
            ["kandidat70", "sentiment.analysis.duration", "company", "Apple", "model", "AI-Powered (AWS Bedrock + Claude)"]
          ]
        }
      },

      {
        "type" : "metric",
        "x" : 0,
        "y" : 12,
        "width" : 6,
        "height" : 6,
        "properties" : {
          "title" : "Companies detected (last analysis)",
          "view" : "singleValue",      # Number-widget
          "region" : "eu-west-1",
          "stat" : "Average",
          "metrics" : [
            ["kandidat70", "sentiment.companies.detected.last"]
          ]
        }
      }
    ]
  })
}