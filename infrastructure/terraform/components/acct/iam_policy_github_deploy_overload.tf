resource "aws_iam_policy" "github_deploy_overload" {
  name        = "${local.csi}-github-deploy-overload"
  description = "Overloads the github permission to perform build actions for services in this account"
  policy      = data.aws_iam_policy_document.github_deploy.json
}

resource "aws_iam_role_policy_attachment" "github_deploy_overload" {
  role       = local.bootstrap.iam_github_deploy_role["name"]
  policy_arn = aws_iam_policy.github_deploy_overload.arn
}

#trivy:ignore:aws-iam-no-policy-wildcards Policy voilation expected for CI user role
data "aws_iam_policy_document" "github_deploy" {
  statement {
    effect = "Allow"

    actions = [
      "grafana:*",
    ]
    resources = ["*"]
  }
}
