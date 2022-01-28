provider "aws" {
  region = "eu-west-1"
}

module "codepipeline" {
  source = "../../../../modules/codepipeline"
  repo_name = "Terraform-Modules"
  codebuild_project_name = "test-build"
  codepipeline_project_name = "terra-pipeline"
  github_user = "Dania8012"
  branch_name = "master"
}
