resource "aws_iam_user" "bbl" {
  name = "${var.env_name}-bbl-perf-tests"
}

resource "aws_iam_access_key" "bbl" {
  user = aws_iam_user.bbl.name
}

resource "aws_iam_user_policy" "bbl" {
  name = "${var.env_name}-bbl"
  user = aws_iam_user.bbl.name

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
          "iam:GetServerCertificate",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:ListPolicyVersions",
          "iam:PutRolePolicy",
          "iam:PassRole",
          "iam:UploadServerCertificate"
        ],
        "Resource" = "*",
      }
    ]
  })
}

resource "aws_iam_user" "cloud_controller" {
  name = "${var.env_name}-cc-perf-tests"
}

resource "aws_iam_access_key" "cloud_controller" {
  user = aws_iam_user.cloud_controller.name
}

resource "aws_iam_user_policy" "cloud_controller" {
  name = "${var.env_name}-cloud_controller"
  user = aws_iam_user.cloud_controller.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Effect" = "Allow",
        "Action" = [
          "s3:*",
        ],
        "Resource" = [
          aws_s3_bucket.cc-blobstore-packages.arn,
          "${aws_s3_bucket.cc-blobstore-packages.arn}/*",
          aws_s3_bucket.cc-blobstore-buildpacks.arn,
          "${aws_s3_bucket.cc-blobstore-buildpacks.arn}/*",
          aws_s3_bucket.cc-blobstore-droplets.arn,
          "${aws_s3_bucket.cc-blobstore-droplets.arn}/*",
          aws_s3_bucket.cc-blobstore-resources.arn,
          "${aws_s3_bucket.cc-blobstore-resources.arn}/*",
        ]
      }   
    ]
  })
}