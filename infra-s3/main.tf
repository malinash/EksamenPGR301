terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "pgr301-terraform-state"
    key    = "kandidat-70/infra-s3/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  bucket_name = "kandidat-${var.candidate_id}-data"
}

resource "aws_s3_bucket" "analysis" {
  bucket = local.bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "analysis" {
  bucket = aws_s3_bucket.analysis.id

  rule {
    id     = "midlertidig-files-lifecycle"
    status = "Enabled"

    # Gjelder bare filer under prefix "midlertidig/"
    filter {
      prefix = "midlertidig/"
    }

    # Flytt til billigere lagringsklasse etter X dager
    transition {
      days          = var.lifecycle_transition_days
      storage_class = "GLACIER"
    }

    # Slett etter Y dager
    expiration {
      days = var.lifecycle_expiration_days
    }
  }
}
