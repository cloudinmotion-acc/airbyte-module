variable "platform_output" {
  type = object({
    name             = string
    system_name      = string
    environment_type = string # "dev", "staging", "prod"
    owner            = string # email
    tags             = map(string)
  })
  description = "UI-provided variables for platform deployment"
}

variable "initialization_output" {
  type = object({
    vpc_id          = string
    region          = string
    kms_key_arn     = string
    private_subnets = list(string)
    public_subnets  = list(string)
    ssh_key_name    = string
  })
  description = "Outputs from init module (REQUIRED dependency)"
}

variable "bastion_host_output" {
  description = "Outputs from bastion module (REQUIRED dependency)"
  type        = any
  default     = null
}

variable "kubernetes_cluster_output" {
  type = object({
    cluster_name     = string
    cluster_endpoint = string
  })
  description = "Outputs from EKS module (REQUIRED dependency)"
}

################################################################################
# Airbyte-Specific Variables
################################################################################

variable "namespace" {
  description = "Kubernetes namespace for Airbyte"
  type        = string
  default     = "airbyte"
}

variable "airbyte_chart_version" {
  description = "Airbyte Helm chart version"
  type        = string
  default     = "1.1.0"
  validation {
    condition     = length(var.airbyte_chart_version) > 0
    error_message = "Airbyte chart version must not be empty."
  }
}

variable "storage_class_name" {
  description = "StorageClass for PVCs"
  type        = string
  default     = "gp3"
}

variable "webapp_port" {
  description = "Port for the Airbyte webapp service"
  type        = number
  default     = 8080
}

variable "api_port" {
  description = "Port for the Airbyte API server"
  type        = number
  default     = 8006
}

variable "db_storage_size" {
  description = "PVC size for the internal PostgreSQL database"
  type        = string
  default     = "10Gi"
}

variable "minio_storage_size" {
  description = "PVC size for MinIO (log/state storage)"
  type        = string
  default     = "10Gi"
}
