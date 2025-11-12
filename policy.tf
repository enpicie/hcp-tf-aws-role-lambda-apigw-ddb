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
          "s3:GetObjectVersion",
          "s3:GetObjectTagging",
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
        "Effect" : "Allow",
        "Action" : [
          "kms:GenerateDataKey",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey"
        ],
        "Resource" : "arn:aws:kms:us-east-2:637423387388:key/*"
      },
      {
        Sid = "PassRoleForLambda",
        # Allows passing execution roles to Lambda functions.
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : "*",
        "Condition" : {
          "StringLikeIfExists" : {
            "iam:PassedToService" : "lambda.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow",
        # Ensures full ability to provision and attach Lambda roles.
        "Action" : [
          "iam:PassRole",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole"
        ],
        "Resource" : [
          # Enforce naming convention for Lambda execution role.
          "arn:aws:iam::637423387388:role/LambdaExecutionRole-*",
          "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
        ]
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
