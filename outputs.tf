output "airbyte_output" {
  description = "Technical outputs for downstream modules"
  value = {
    namespace       = kubernetes_namespace_v1.airbyte.metadata[0].name
    helm_release    = helm_release.airbyte.name
    webapp_endpoint = "${helm_release.airbyte.name}-airbyte-webapp.${kubernetes_namespace_v1.airbyte.metadata[0].name}.svc.cluster.local"
    webapp_port     = var.webapp_port
    api_endpoint    = "${helm_release.airbyte.name}-airbyte-server.${kubernetes_namespace_v1.airbyte.metadata[0].name}.svc.cluster.local"
    api_port        = var.api_port
    chart_version   = var.airbyte_chart_version
  }
}

output "mpp_report" {
  description = "Human-readable report for platform UI"
  value = {
    "Component"       = "Airbyte Data Integration Platform"
    "Namespace"       = kubernetes_namespace_v1.airbyte.metadata[0].name
    "Chart Version"   = var.airbyte_chart_version
    "Webapp Endpoint" = "${helm_release.airbyte.name}-airbyte-webapp.${kubernetes_namespace_v1.airbyte.metadata[0].name}.svc.cluster.local:${var.webapp_port}"
    "API Endpoint"    = "${helm_release.airbyte.name}-airbyte-server.${kubernetes_namespace_v1.airbyte.metadata[0].name}.svc.cluster.local:${var.api_port}"
    "Database"        = "Internal PostgreSQL (${var.db_storage_size} PVC)"
    "Log Storage"     = "Internal MinIO (${var.minio_storage_size} PVC)"
    "Storage Class"   = var.storage_class_name
  }
}
