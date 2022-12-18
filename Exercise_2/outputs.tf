# TODO: Define the output variable for the lambda function.
output "udacity_greet_lambda" {
  value = aws_lambda_function.udacity_greet_lambda.id
}