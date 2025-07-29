resource "aws_iam_policy" "lambda_apigw_ddb_full_access" {
  name        = "Terraform-FullAccess-Lambda-APIGateway-DynamoDB"
  description = "Allows HCP Terraform to provision AWS Lambda, API Gateway, and DynamoDB resources"
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "LambdaFullAccess",
        Effect = "Allow",
        Action = [
          "lambda:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "APIGatewayFullAccess",
        Effect = "Allow",
        Action = [
          "apigateway:*"
        ],
        Resource = "*"
      },
      {
        Sid    = "DynamoDBFullAccess",
        Effect = "Allow",
        Action = [
          "dynamodb:*"
        ],
        Resource = "*"
      },
      {
        # Needed to allow Lambda functions to access S3 buckets for deployment artifacts.
        # The need for this is implied in creation of lambdas so S3 is not included in role name.
        Sid    = "S3AccessForLambdaDeployment",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::enpicie-dev-lambda-artifacts",
          "arn:aws:s3:::enpicie-dev-lambda-artifacts/*",
          "arn:aws:s3:::enpicie-prod-lambda-artifacts",
          "arn:aws:s3:::enpicie-prod-lambda-artifacts/*"
        ]
      },
      {
        Sid    = "PassRoleForLambda",
        Effect = "Allow",
        # Allows passing execution roles to Lambda functions.
        Action   = "iam:PassRole",
        Resource = "*",
        Condition = {
          StringLikeIfExists = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      },
      {
        # Needed to provision logging groups for Lambda functions.
        Sid    = "CloudWatchLogs",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
