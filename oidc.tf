# Policy document for the IAM role that allows Terraform Cloud to assume the role using OIDC.
data "aws_iam_policy_document" "hcp_oidc_assume_role_policy" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.hcp_terraform.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "app.terraform.io:aud"
      values   = ["aws.workload.identity"]
    }

    condition {
      test     = "StringLike"
      variable = "app.terraform.io:sub"
      # Allows role to be used for any work done in the organization.
      values = ["organization:*"]
    }
  }
}
