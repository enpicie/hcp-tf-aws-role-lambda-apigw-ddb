data "aws_iam_openid_connect_provider" "hcp_terraform" {
  arn = var.oidc_provider_arn
}

# IAM role for Terraform Cloud to assume with full access to Lambda, API Gateway, DynamoDB.
# Role can be assumed by Terraform Cloud using OIDC via config above.
# Policy document is defined in oidc.tf.
resource "aws_iam_role" "lambda_apigw_ddb_full_access" {
  name               = "lambda-apigw-ddb-full-access-role"
  assume_role_policy = data.aws_iam_policy_document.hcp_oidc_assume_role_policy.json
}

# Attaches permissions for Lambda and API Gateway to role.
# Policy is defined in policy.tf.
resource "aws_iam_role_policy_attachment" "lambda_apigw_ddb_full_access" {
  policy_arn = aws_iam_policy.lambda_apigw_ddb_full_access.arn
  role       = aws_iam_role.lambda_apigw_ddb_full_access.name
}

data "tfe_organization" "hcp_organization" {
  name = var.hcp_organization_name
}

resource "tfe_variable_set" "lambda_apigw_ddb_role_var_set" {
  name         = "AWS HCP TF OIDC Role - Lambda+APIGateway+DynamoDB Perms"
  description  = "OIDC federation configuration for ${aws_iam_role.lambda_apigw_ddb_full_access.name}"
  organization = data.tfe_organization.hcp_organization.name
  global       = false
}

resource "tfe_variable" "tfc_aws_provider_auth" {
  key             = "TFC_AWS_PROVIDER_AUTH"
  value           = "true"
  category        = "env"
  variable_set_id = tfe_variable_set.lambda_apigw_ddb_role_var_set.id
}

resource "tfe_variable" "tfc_aws_run_role_arn" {
  sensitive       = true
  key             = "TFC_AWS_RUN_ROLE_ARN"
  value           = aws_iam_role.lambda_apigw_ddb_full_access.arn
  category        = "env"
  variable_set_id = tfe_variable_set.lambda_apigw_ddb_role_var_set.id
}
