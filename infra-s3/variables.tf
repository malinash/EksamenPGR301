variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "candidate_id" {
  description = "70"
  type        = string
}

variable "lifecycle_transition_days" {
  description = "Antall dager før midlertidige filer flyttes til GLACIER"
  type        = number
  default     = 7
}

variable "lifecycle_expiration_days" {
  description = "Antall dager før midlertidige filer slettes"
  type        = number
  default     = 30
}