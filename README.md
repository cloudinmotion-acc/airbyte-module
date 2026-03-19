# Airbyte Terraform Module

Deploys [Airbyte](https://airbyte.com) (data integration platform) on an existing EKS cluster using the official Helm chart. Includes internal PostgreSQL, MinIO, and a network policy.

## Architecture

- **Helm chart**: `airbyte` from `https://airbytehq.github.io/helm-charts`
- **Database**: Internal PostgreSQL on a PVC (gp3 EBS)
- **Log/state storage**: Internal MinIO on a PVC (gp3 EBS)
- **Network**: ClusterIP services only (access via port-forward or bastion)
- **Resource sizing**: Automatically scaled based on environment type (`dev`/`staging` vs `prod`)

## Prerequisites

| Dependency | Description |
|------------|-------------|
| `platform_output` | Platform naming, environment, owner, and tags |
| `initialization_output` | VPC, region, KMS key, subnets, SSH key |
| `kubernetes_cluster_output` | EKS cluster name and endpoint |

## Usage

```hcl
module "airbyte" {
  source = "./airbyte-module"

  platform_output = {
    name             = "myproject"
    system_name      = "myproject"
    environment_type = "dev"
    owner            = "team@example.com"
    tags             = { Project = "myproject" }
  }

  initialization_output = {
    vpc_id          = "vpc-0abc123"
    region          = "us-east-1"
    kms_key_arn     = "arn:aws:kms:us-east-1:123456789:key/abc-123"
    private_subnets = ["subnet-aaa", "subnet-bbb"]
    public_subnets  = ["subnet-ccc", "subnet-ddd"]
    ssh_key_name    = "my-key"
  }

  kubernetes_cluster_output = {
    cluster_name     = "my-eks-cluster"
    cluster_endpoint = "https://ABCD1234.us-east-1.eks.amazonaws.com"
  }

  # Optional overrides
  namespace             = "airbyte"
  airbyte_chart_version = "1.1.0"
  storage_class_name    = "gp3"
  db_storage_size       = "10Gi"
  minio_storage_size    = "10Gi"
}
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `platform_output` | Platform deployment context (required) | - |
| `initialization_output` | Init module outputs (required) | - |
| `kubernetes_cluster_output` | EKS module outputs (required) | - |
| `bastion_host_output` | Bastion module outputs | `null` |
| `namespace` | Kubernetes namespace | `"airbyte"` |
| `airbyte_chart_version` | Helm chart version | `"1.1.0"` |
| `storage_class_name` | StorageClass for PVCs | `"gp3"` |
| `webapp_port` | Webapp service port | `8080` |
| `api_port` | API server port | `8006` |
| `db_storage_size` | PostgreSQL PVC size | `"10Gi"` |
| `minio_storage_size` | MinIO PVC size | `"10Gi"` |

## Outputs

### `airbyte_output`

Technical outputs for downstream module consumption:

| Key | Example |
|-----|---------|
| `namespace` | `airbyte` |
| `helm_release` | `myproject-airbyte-dev` |
| `webapp_endpoint` | `myproject-airbyte-dev-airbyte-webapp.airbyte.svc.cluster.local` |
| `webapp_port` | `8080` |
| `api_endpoint` | `myproject-airbyte-dev-airbyte-server.airbyte.svc.cluster.local` |
| `api_port` | `8006` |
| `chart_version` | `1.1.0` |

### `mpp_report`

Human-readable report for platform UI display.

## Resource Sizing

Resources are automatically configured based on `environment_type`:

| Component | Dev/Staging | Prod |
|-----------|-------------|------|
| Webapp CPU | 200m-500m | 500m-1000m |
| Webapp Memory | 512Mi | 1Gi |
| Server CPU | 250m-500m | 500m-1000m |
| Server Memory | 1Gi | 2Gi |
| Worker CPU | 500m-1000m | 1000m-2000m |
| Worker Memory | 2Gi | 4Gi |
| Worker Replicas | 1 | 2 |

## Accessing Airbyte

Services use ClusterIP (no external exposure). Access via port-forward:

```bash
# Webapp UI
kubectl port-forward svc/<release>-airbyte-webapp-svc 8080:8080 -n airbyte

# API Server
kubectl port-forward svc/<release>-airbyte-server-svc 8001:8001 -n airbyte
```

## Naming Convention

All resources follow the pattern: `{system_name}-airbyte-{environment_type}`

Example: `demomar017-airbyte-dev`
