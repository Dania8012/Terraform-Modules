variable "codepipeline_project_name" {
  description = "CodePipeline project name"
  default = ""
}

variable "codebuild_project_name" {
  description = "CodeBuild project name"
  default = ""
}

variable "repo_name" {
  description = "Source repository name"
  default = ""
}

variable "github_user" {
  description = "Github username"
  default = ""
}

variable "branch_name" {
  description = "Github branch to be used as source"
  default = "master"
}