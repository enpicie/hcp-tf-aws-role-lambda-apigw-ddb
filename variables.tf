variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2" # Ohio
}

variable "oidc_provider_arn" {
  description = "ARN of the existing OIDC provider"
  type        = string
  default     = "arn:aws:iam::637423387388:oidc-provider/app.terraform.io"
}

variable "hcp_organization_name" {
  description = "HCP organization name"
  type        = string
  default     = "enpicie"
}
