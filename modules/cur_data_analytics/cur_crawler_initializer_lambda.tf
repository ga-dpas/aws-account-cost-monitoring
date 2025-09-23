# ---------------------------------------------------
# AWS Glue cur_crawler Lambda
# Alternate option to schedule for initializing the cur_crawler
# ---------------------------------------------------
locals {
  enable_cur_crawler_initializer_lambda = false
  cur_crawler_initializer_lambda_name   = "${var.resource_prefix}-CURCrawlerInitializer"
}

data "archive_file" "cur_crawler_initializer_lambda_code" {
  count       = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/${local.cur_crawler_initializer_lambda_name}.zip"
}

data "aws_iam_policy_document" "cur_crawler_initializer_lambda_assume" {
  count = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cur_crawler_initializer_lambda_policy" {
  count = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  statement {
    sid    = "CloudWatch"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
    resources = ["${aws_cloudwatch_log_group.cur_crawler_initializer_initializer[0].arn}:*"]
  }

  statement {
    sid    = "Glue"
    effect = "Allow"
    actions = [
      "glue:Startcur_crawler",
    ]
    resources = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "cur_crawler_initializer_initializer" {
  count             = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  name              = "/aws/lambda/${local.cur_crawler_initializer_lambda_name}"
  retention_in_days = 7
}

resource "aws_lambda_permission" "cur_crawler_initializer_initializer" {
  count          = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  statement_id   = "${var.resource_prefix}-AllowDataExportS3ToInvokeLambda"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.cur_crawler_initializer_initializer[0].function_name
  source_account = data.aws_caller_identity.current.account_id
  principal      = "s3.amazonaws.com"
  source_arn     = local.data_export_bucket_name
}

resource "aws_iam_role" "cur_crawler_initializer_executor" {
  count              = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  name               = "${local.cur_crawler_initializer_lambda_name}-executor"
  assume_role_policy = data.aws_iam_policy_document.cur_crawler_initializer_lambda_assume[0].json
}

resource "aws_iam_role_policy" "cur_crawler_initializer_policy" {
  count  = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  name   = "${local.cur_crawler_initializer_lambda_name}-policy"
  role   = aws_iam_role.cur_crawler_initializer_executor[0].name
  policy = data.aws_iam_policy_document.cur_crawler_initializer_lambda_policy[0].json
}

resource "aws_lambda_function" "cur_crawler_initializer_initializer" {
  count                          = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  function_name                  = local.cur_crawler_initializer_lambda_name
  filename                       = data.archive_file.cur_crawler_initializer_lambda_code[0].output_path
  handler                        = "${local.cur_crawler_initializer_lambda_name}.lambda_handler"
  runtime                        = "python3.11"
  reserved_concurrent_executions = 1
  role                           = aws_iam_role.cur_crawler_initializer_executor[0].arn
  timeout                        = 30
  source_code_hash               = data.archive_file.cur_crawler_initializer_lambda_code[0].output_base64sha256
  environment {
    variables = {
      CRAWLER_NAME = aws_glue_crawler.cur2_crawler[0].name
    }
  }
}

resource "aws_s3_bucket_notification" "cur_initializer_lambda_trigger" {
  count  = local.enable_cur_crawler_initializer_lambda ? 1 : 0
  bucket = local.data_export_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.cur_crawler_initializer_initializer[0].arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = local.cur2_crawler_s3_path
    filter_suffix       = ".parquet"
  }
}