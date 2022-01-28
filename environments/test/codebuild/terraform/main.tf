provider "aws" {
  region = "eu-west-1"
}

module "codebuild" {
  source = "../../../../modules/codebuild"
  build_project_name = "test-build"
  build_project_description = "test build project"
}