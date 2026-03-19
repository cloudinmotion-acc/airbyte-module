################################################################################
# Namespace
################################################################################

resource "kubernetes_namespace_v1" "airbyte" {
  metadata {
    name   = var.namespace
    labels = local.common_labels
  }
}

################################################################################
# Airbyte Helm Release
# Deploys the full Airbyte stack: webapp, server, worker, temporal, db, minio
# All storage uses internal PVCs on gp3 (encrypted EBS) - no external services
################################################################################

resource "helm_release" "airbyte" {
  name       = local.resource_prefix
  namespace  = kubernetes_namespace_v1.airbyte.metadata[0].name
  repository = "https://airbytehq.github.io/helm-charts"
  chart      = "airbyte"
  version    = var.airbyte_chart_version
  timeout    = 300

  # Global settings
  set {
    name  = "global.storageClass"
    value = var.storage_class_name
  }

  # Webapp configuration - ClusterIP only, access via port-forward or bastion
  set {
    name  = "webapp.service.type"
    value = "ClusterIP"
  }

  set {
    name  = "webapp.service.port"
    value = var.webapp_port
  }

  set {
    name  = "webapp.resources.requests.cpu"
    value = local.resource_config.webapp_cpu_request
  }

  set {
    name  = "webapp.resources.limits.cpu"
    value = local.resource_config.webapp_cpu_limit
  }

  set {
    name  = "webapp.resources.requests.memory"
    value = local.resource_config.webapp_memory
  }

  set {
    name  = "webapp.resources.limits.memory"
    value = local.resource_config.webapp_memory
  }

  # Server configuration
  set {
    name  = "server.resources.requests.cpu"
    value = local.resource_config.server_cpu_request
  }

  set {
    name  = "server.resources.limits.cpu"
    value = local.resource_config.server_cpu_limit
  }

  set {
    name  = "server.resources.requests.memory"
    value = local.resource_config.server_memory
  }

  set {
    name  = "server.resources.limits.memory"
    value = local.resource_config.server_memory
  }

  # Worker configuration
  set {
    name  = "worker.replicaCount"
    value = local.resource_config.worker_replicas
  }

  set {
    name  = "worker.resources.requests.cpu"
    value = local.resource_config.worker_cpu_request
  }

  set {
    name  = "worker.resources.limits.cpu"
    value = local.resource_config.worker_cpu_limit
  }

  set {
    name  = "worker.resources.requests.memory"
    value = local.resource_config.worker_memory
  }

  set {
    name  = "worker.resources.limits.memory"
    value = local.resource_config.worker_memory
  }

  # Internal PostgreSQL on PVC
  set {
    name  = "postgresql.enabled"
    value = true
  }

  set {
    name  = "postgresql.primary.persistence.size"
    value = var.db_storage_size
  }

  set {
    name  = "postgresql.primary.persistence.storageClass"
    value = var.storage_class_name
  }

  # Internal MinIO on PVC for log/state storage
  set {
    name  = "minio.enabled"
    value = true
  }

  set {
    name  = "minio.persistence.size"
    value = var.minio_storage_size
  }

  set {
    name  = "minio.persistence.storageClass"
    value = var.storage_class_name
  }

  # Pod sweeper: bitnami/kubectl no longer publishes semver tags, only digests
  # Use "latest" which is the only named tag still available
  set {
    name  = "pod-sweeper.image.tag"
    value = "latest"
  }
}

################################################################################
# Network Policy
# Default deny with explicit allow: ingress from any cluster namespace,
# egress to all (required for connector image pulls and data source access)
################################################################################

resource "kubernetes_network_policy_v1" "airbyte" {
  metadata {
    name      = "${local.resource_prefix}-network-policy"
    namespace = kubernetes_namespace_v1.airbyte.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    pod_selector {}

    # Allow ingress from any namespace within the cluster
    ingress {
      from {
        namespace_selector {}
      }
    }

    # Allow all egress - required for connector access to external data sources
    egress {}

    policy_types = ["Ingress", "Egress"]
  }
}
