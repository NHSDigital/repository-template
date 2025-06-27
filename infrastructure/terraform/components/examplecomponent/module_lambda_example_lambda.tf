# module "example_lambda" {
#   source = "git::https://github.com/NHSDigital/nhs-notify-shared-modules.git//infrastructure/modules/lambda?ref=v2.0.10"

#   function_name = "example-lambda"
#   description   = "An example lambda function"

#   aws_account_id = var.aws_account_id
#   component      = var.component
#   environment    = var.environment
#   project        = var.project
#   region         = var.region
#   group          = var.group

#   log_retention_in_days = var.log_retention_in_days
#   kms_key_arn           = module.kms.key_arn ## Requires shared kms module

#   iam_policy_document = {
#     body = data.aws_iam_policy_document.example_lambda.json
#   }

#   function_s3_bucket      = local.acct.s3_buckets["lambda_function_artefacts"]["id"]
#   function_code_base_path = local.aws_lambda_functions_dir_path
#   function_code_dir       = "example-lambda/dist"
#   function_include_common = true
#   handler_function_name   = "handler"
#   runtime                 = "nodejs22.x"
#   memory                  = 128
#   timeout                 = 5
#   log_level               = var.log_level

#   force_lambda_code_deploy = var.force_lambda_code_deploy
#   enable_lambda_insights   = false

#   lambda_env_vars = {
#   }
# }

# data "aws_iam_policy_document" "example_lambda" {
#   statement {
#     sid    = "KMSPermissions"
#     effect = "Allow"

#     actions = [
#       "kms:Decrypt",
#       "kms:GenerateDataKey",
#     ]

#     resources = [
#       module.kms.key_arn, ## Requires shared kms module
#     ]
#   }
# }
