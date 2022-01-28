provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Terraform = true
    }
  }
}

resource "aws_iam_role" "build_project_role" {
  name = format("%s-role", var.build_project_name) 
  path = "/service-role/"

  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_codebuild_project" "build_project" {
  name           = var.build_project_name
  description    = var.build_project_description
  build_timeout  = "60"
  queued_timeout = "480"

  service_role = aws_iam_role.build_project_role.arn
  source {
    buildspec = "buildspec.yml"
    type      = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
}

