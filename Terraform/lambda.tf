# IAM ROLE FOR LAMBDA
resource "aws_iam_role" "lambda_role" {
  name = "selfheal-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Effect = "Allow"
    }]
  })
}

# IAM POLICY FOR LAMBDA
resource "aws_iam_role_policy" "lambda_ec2_policy" {
  name = "selfheal-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:TerminateInstances",
          "ec2:RunInstances",
          "ec2:DescribeImages",
          "ec2:CreateTags"
        ],
        Resource = "*"
      },
      {
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

# LAMBDA FUNCTION
resource "aws_lambda_function" "selfheal_lambda" {
  function_name = "selfheal-ec2-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 60
  memory_size   = 128

  filename         = "${path.module}/../Scripts/selfheal_lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../Scripts/selfheal_lambda.zip")

  environment {
    variables = {
      INSTANCE_ID   = aws_instance.selfheal_ec2.id
      AMI_ID        = var.ami_id
      SG_ID         = aws_security_group.selfheal_sg.id
      KEY_NAME      = var.key_name
      INSTANCE_TYPE = var.instance_type
    }
  }
}

# EVENTBRIDGE RULE (EC2 STATE CHANGE)
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change"
  description = "Trigger Lambda on EC2 stop/terminate"

  event_pattern = jsonencode({
    source = ["aws.ec2"],
    "detail-type" = ["EC2 Instance State-change Notification"],
    detail = {
      state = ["stopped", "terminated"]
    }
  })
}

# EVENTBRIDGE TARGET (LAMBDA)
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  target_id = "SelfHealLambda"
  arn       = aws_lambda_function.selfheal_lambda.arn
}

# PERMISSION FOR EVENTBRIDGE
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.selfheal_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change.arn
}
