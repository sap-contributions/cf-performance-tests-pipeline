resource "aws_iam_user" "pipeline-user" {
  name = "${var.env_name}-perf-tests"
}

resource "aws_iam_access_key" "pipeline-user" {
  user = aws_iam_user.pipeline-user.name
}

resource "aws_iam_user_policy" "bbl" {
  name = "${var.env_name}-bbl"
  user = aws_iam_user.pipeline-user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" = "Allow",
        "Action" = [
          "logs:*",
          "elasticloadbalancing:*",
          "cloudformation:*",
          "kms:*",
          "ec2:*",
        ],
        "Resource" = "*",
        "Condition" = {
          "StringEquals" = {
            "aws:RequestedRegion" = var.region
          }
        }
      },
      {
        "Effect" = "Allow",
        "Action" = [
          "route53:*",
          "iam:AddRoleToInstanceProfile",
          "iam:AttachRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:CreatePolicy",
          "iam:CreateRole",
          "iam:DeleteInstanceProfile",
          "iam:DeletePolicy",
          "iam:DeleteRole",
          "iam:DetachRolePolicy",
          "iam:GetInstanceProfile",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListPolicyVersions"
        ],
        "Resource" = "*",
      }
    ]
  })
}
