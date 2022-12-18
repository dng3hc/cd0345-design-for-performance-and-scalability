provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# create zip archive of code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "lambda_function.zip"
}

# IAM role for lambda func
resource "aws_iam_role" "iam_role_for_lambda" {
  name = "iam_udacity_lambda"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}

# IAM policy for lambda logging
resource "aws_iam_policy" "iam_policy_lambda_logging" {
  name        = "udacity_lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      }
    ]
  })
}

# IAM attachment
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_role_for_lambda.name
  policy_arn = aws_iam_policy.iam_policy_lambda_logging.arn
}

# lambda func
resource "aws_lambda_function" "udacity_greet_lambda" {
  filename      = "lambda_function.zip"
  function_name = "udacity_greet_lambda"
  handler       = "greet_lambda.lambda_handler"
  role          = aws_iam_role.iam_role_for_lambda.arn
  runtime = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  depends_on = [aws_iam_role_policy_attachment.lambda_logs]

  environment {
    variables = {
      greeting = "Greeting from Quoc Dung!"
    }
  }
}