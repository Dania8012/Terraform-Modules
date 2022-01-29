
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-storage2022"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "rds_instance" {
  source                       = "../../../modules/rds"
  name                         = "terraform-demo"
  storage                      = 10
  engine                       = "mysql"
  port                         = "3306"
  engine_version               = "5.7"
  instance_class               = "db.t3.micro"
  db_name                      = "mydb"
  username                     = "dania"
  password                     = "password123"
  parameter_group_name         = "default.mysql5.7"
  parameter_group_family       = "mysql5.7"
  allow_major_version_upgrade  = false
  monitoring_interval          = 60
  performance_insights_enabled = true
  skip_final_snapshot          = true
  vpc_id                       = data.terraform_remote_state.vpc.outputs.vpc[0].id
  iam_role_name                = "db-test"
  iam_role_description         = "RDS enhanced monitoring IAM role"
}
