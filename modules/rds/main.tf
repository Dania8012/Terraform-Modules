provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Terraform = true
    }
  }
}

# Locals
locals {

  rds_enhanced_monitoring_arn = var.create_monitoring_role ? join("", aws_iam_role.rds_enhanced_monitoring.*.arn) : var.monitoring_role_arn
  rds_security_group_id       = join("", aws_security_group.this.*.id)

  iam_role_name        = var.iam_role_use_name_prefix ? null : coalesce(var.iam_role_name, "rds-enhanced-monitoring-${var.name}")
  iam_role_name_prefix = var.iam_role_use_name_prefix ? "${var.iam_role_name}-" : null
}


# Network settings

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "terraform-state-storage2022"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "aws_db_subnet_group" "this" {
  name        = "${var.name}-sg"
  description = "For RDS cluster ${var.name}"
  subnet_ids  = data.terraform_remote_state.vpc.outputs.private_subnets.*.id
}

# DB settings

resource "aws_db_parameter_group" "this" {
  name   = "${var.name}-db-pg"
  family = var.parameter_group_family
}

resource "aws_security_group" "this" {
  name   = "${var.name}-db"
  vpc_id = var.vpc_id

  description = var.security_group_description == "" ? "Control traffic to/from RDS Aurora ${var.name}" : var.security_group_description
}

# Monitoring settings

data "aws_iam_policy_document" "monitoring_rds_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  name        = local.iam_role_name
  name_prefix = local.iam_role_name_prefix
  description = var.iam_role_description
  path        = var.iam_role_path

  assume_role_policy    = data.aws_iam_policy_document.monitoring_rds_assume_role.json
  managed_policy_arns   = var.iam_role_managed_policy_arns
  permissions_boundary  = var.iam_role_permissions_boundary
  force_detach_policies = var.iam_role_force_detach_policies
  max_session_duration  = var.iam_role_max_session_duration
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Other settings

resource "random_id" "snapshot_identifier" {
  keepers = {
    id = var.name
  }
  byte_length = 4
}

data "aws_partition" "current" {}


# RDS module definition

resource "aws_db_instance" "this" {
  identifier                          = var.name
  allocated_storage                   = var.storage
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  name                                = var.db_name
  username                            = var.username
  password                            = var.password
  apply_immediately                   = var.apply_immediately
  parameter_group_name                = aws_db_parameter_group.this.name
  allow_major_version_upgrade         = var.allow_major_version_upgrade
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  backup_retention_period             = var.backup_retention_period
  backup_window                       = var.backup_window
  ca_cert_identifier                  = var.ca_cert_identifier
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  final_snapshot_identifier           = "${var.final_snapshot_identifier_prefix}-${var.name}-${element(concat(random_id.snapshot_identifier.*.hex, [""]), 0)}"
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  kms_key_id                          = var.kms_key_id
  maintenance_window                  = var.maintenance_window
  port                                = var.port
  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = local.rds_enhanced_monitoring_arn
  # performance_insights_enabled        = var.performance_insights_enabled
  # performance_insights_kms_key_id     = var.performance_insights_kms_key_id
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot
  storage_encrypted      = var.storage_encrypted
  vpc_security_group_ids = compact(concat(aws_security_group.this.*.id, var.vpc_security_group_ids))
  db_subnet_group_name   = aws_db_subnet_group.this.name
  deletion_protection    = var.deletion_protection

  dynamic "s3_import" {
    for_each = var.s3_import != null ? [var.s3_import] : []
    content {
      source_engine         = var.engine
      source_engine_version = s3_import.value.source_engine_version
      bucket_name           = s3_import.value.bucket_name
      bucket_prefix         = lookup(s3_import.value, "bucket_prefix", null)
      ingestion_role        = s3_import.value.ingestion_role
    }
  }
}
