resource "aws_codebuild_project" "my_codebuild_project" {
  name          = "my-codebuild-project"
  description   = "Build project for MyRepository"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = data.aws_region.current.name
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.ghost-ecr-repository.name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name  = "EXECUTION_ROLE_ARN"
      value = var.ecs_execution_role_arn
    }
    environment_variable {
      name  = "DB_HOST"
      value = var.db_host
    }
    environment_variable {
      name  = "DB_PASSWORD"
      value = var.db_password
    }
    environment_variable {
      name  = "GHOST_URL"
      value = var.ghost_url
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yml")
  }

  cache {
    type = "NO_CACHE"
  }
}


resource "aws_iam_role" "codebuild_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "codebuild.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_policy" "codebuild_policy" {
  name        = "codebuild_policy"
  description = "Policy for CodeBuild to access resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Action   = "codecommit:Get*",
        Effect   = "Allow",
        Resource = "${aws_codecommit_repository.ghost-repo.arn}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attach" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}
