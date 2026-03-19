locals {
  common_tags = merge(var.platform_output.tags, {
    "Owner"       = var.platform_output.owner
    "Environment" = var.platform_output.environment_type
  })

  # Naming convention: system_name-component-environment_type
  resource_prefix = "${var.platform_output.system_name}-airbyte-${var.platform_output.environment_type}"

  # Environment-based resource sizing
  # prod=larger for concurrent syncs; dev/staging=smaller to save cost
  resource_config = {
    webapp_cpu_request = var.platform_output.environment_type == "prod" ? "500m" : "200m"
    webapp_cpu_limit   = var.platform_output.environment_type == "prod" ? "1000m" : "500m"
    webapp_memory      = var.platform_output.environment_type == "prod" ? "1Gi" : "512Mi"
    server_cpu_request = var.platform_output.environment_type == "prod" ? "500m" : "250m"
    server_cpu_limit   = var.platform_output.environment_type == "prod" ? "1000m" : "500m"
    server_memory      = var.platform_output.environment_type == "prod" ? "2Gi" : "1Gi"
    worker_cpu_request = var.platform_output.environment_type == "prod" ? "1000m" : "500m"
    worker_cpu_limit   = var.platform_output.environment_type == "prod" ? "2000m" : "1000m"
    worker_memory      = var.platform_output.environment_type == "prod" ? "4Gi" : "2Gi"
    worker_replicas    = var.platform_output.environment_type == "prod" ? 2 : 1
  }

  # Standard Kubernetes labels following app.kubernetes.io convention
  common_labels = merge(var.platform_output.tags, {
    "app.kubernetes.io/name"       = "airbyte"
    "app.kubernetes.io/instance"   = local.resource_prefix
    "app.kubernetes.io/component"  = "data-integration"
    "app.kubernetes.io/managed-by" = "terraform"
    "Owner"                        = var.platform_output.owner
    "Environment"                  = var.platform_output.environment_type
  })

  # Selector labels must be a subset of common_labels
  match_labels = {
    "app.kubernetes.io/name"     = "airbyte"
    "app.kubernetes.io/instance" = local.resource_prefix
  }
}
