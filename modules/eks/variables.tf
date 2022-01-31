variable "name" {
  type        = string
  description = "The name of EKS cluster"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs in which EKS Cluster will be created in"
  default     = []
}