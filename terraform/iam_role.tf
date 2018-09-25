module "iam_assume_role" {
  source                        = "anonymint/iam-role/aws"
  role_name                     = "codebuild-${var.namespace}-service-role"
  policy_arns_count             = "1"
  policy_arns                   = ["${aws_iam_policy.codebuild.arn}"]
  create_instance_role          = true
  iam_role_policy_document_json = "${data.aws_iam_policy_document.codebuild-service-role.json}"
}

# ROLE Policy
data "aws_iam_policy_document" "codebuild-service-role" {
  statement {
  actions = ["sts:AssumeRole"]
  principals {
    type = "Service"
    identifiers = [
      "codebuild.amazonaws.com"
    ]
  }
  effect = "Allow"
  }
}
