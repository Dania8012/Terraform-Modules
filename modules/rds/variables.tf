variable "name" {
  description = "The name of RDS cluster"
  default     = ""
}

variable "storage" {
  description = "Storage of RDS cluster (GB)"
  default     = 10
}

variable "engine" {
  description = "The engine of RDS cluster"
  default     = ""
}

variable "port" {
  description = "The port on which to accept connections"
  type        = string
  default     = ""
}

variable "engine_version" {
  description = "The engine version of RDS instance"
  default     = ""
}

variable "instance_class" {
  description = "The instance class of the RDS instance"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The DB name"
  default     = ""
}

variable "username" {
  description = "Username for DB access"
  default     = ""
}

variable "password" {
  description = "Password for DB access"
  default     = ""
}

variable "parameter_group_name" {
  description = "Parameter group name"
  default     = ""
}

variable "parameter_group_family" {
  description = "Parameter group family"
  default     = ""
}

variable "allow_major_version_upgrade" {
  description = "Determines whether major engine upgrades are allowed when changing engine version"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "How long to keep backups for (in days)"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "When to perform DB backups"
  type        = string
  default     = "02:00-03:00"
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance"
  type        = string
  default     = null
}

variable "db_subnet_group_name" {
  description = "The existing subnet group name to use"
  type        = string
  default     = ""
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled"
  type        = bool
  default     = false
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to cloudwatch - `audit`, `error`, `general`, `slowquery`, `postgresql`"
  type        = list(string)
  default     = []
}

variable "final_snapshot_identifier_prefix" {
  description = "The prefix name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too."
  type        = string
  default     = "final"
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether IAM Database authentication should be enabled or not. Not all versions and instances are supported. Refer to the AWS documentation to see which versions are supported"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key if one is set to the cluster"
  type        = string
  default     = ""
}

variable "maintenance_window" {
  description = "When to perform DB maintenance"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not"
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data"
  type        = string
  default     = ""
}

variable "publicly_accessible" {
  description = "Whether the DB should have a public IP address"
  type        = bool
  default     = false
}

variable "s3_import" {
  description = "Configuration map used to restore from a Percona Xtrabackup in S3 (only MySQL is supported)"
  type        = map(string)
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created."
  type        = bool
  default     = false
}

variable "snapshot_identifier" {
  description = "DB snapshot to create this database from"
  type        = string
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the underlying storage layer should be encrypted"
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate to the cluster in addition to the SG we create in this module"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default     = ""
}

variable "security_group_description" {
  description = "The description of the security group. If value is set to empty string it will contain cluster name in the description"
  type        = string
  default     = "Managed by Terraform"
}

# Enhanced monitoring
variable "iam_role_name" {
  description = "Friendly name of the role"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Whether to use `iam_role_name` as is or create a unique name beginning with the `iam_role_name` as the prefix"
  type        = bool
  default     = false
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path to the role"
  type        = string
  default     = null
}

variable "iam_role_managed_policy_arns" {
  description = "Set of exclusive IAM managed policy ARNs to attach to the IAM role"
  type        = list(string)
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "The ARN of the policy that is used to set the permissions boundary for the role"
  type        = string
  default     = null
}

variable "iam_role_force_detach_policies" {
  description = "Whether to force detaching any policies the role has before destroying it"
  type        = bool
  default     = null
}

variable "iam_role_max_session_duration" {
  description = "Maximum session duration (in seconds) that you want to set for the role"
  type        = number
  default     = null
}

variable "monitoring_interval" {
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
  type        = number
  default     = 0
}

variable "create_monitoring_role" {
  description = "Whether to create the IAM role for RDS enhanced monitoring"
  type        = bool
  default     = true
}

variable "monitoring_role_arn" {
  description = "IAM role used by RDS to send enhanced monitoring metrics to CloudWatch"
  type        = string
  default     = ""
}

