variable "name" {
  type        = string
  description = "The name of EKS Node Group"
  default     = ""
}

variable "cluster_name" {
  type        = string
  description = "The name of EKS cluster in which the Node Group will be created in"
  default     = ""
}

variable "disk_size" {
  type        = number
  description = "The disk size of the create EC2 instance(s)"
  default     = 20
}

variable "instance_type" {
  type        = string
  description = "The instance type of the created EC2 instance"
  default     = "t2.micro"
}

variable "min_size" {
  type        = number
  description = "The min number of EC2 instances"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "The max number of EC2 instances"
  default     = 1
}

variable "desired_size" {
  type        = number
  description = "The desired number of EC2 instances"
  default     = 1
}

variable "max_unavailable" {
  type        = number
  description = "The max number of unavailable instances"
  default     = 1
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs in which Node Group will be created in"
  default     = []
}