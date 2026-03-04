# Resource Optimization Pass

This document summarizes the resource optimization pass performed to reduce the CPU and Memory footprint of the GCP implementation.

## Summary of Changes

### 1. Liferay Chart
**File:** `cloud/helm/gcp/values.yaml`

| Resource | Original Request | Optimized Request | Savings |
| :--- | :--- | :--- | :--- |
| CPU | 2000m | 500m | 1500m (1.5 cores) |
| Memory | 2Gi | 1.5Gi | 0.5Gi |

### 2. Crossplane Providers
**File:** `cloud/helm/gcp-infrastructure-provider/templates/runtime-configs.yaml`

Targeted providers that were previously using higher limits (`1000m` CPU, `1.5Gi` RAM):
- `gcp-sql-config`
- `gcp-compute-config`
- `gcp-cloudplatform-config`

| Resource | Previous Limit | Optimized Limit | Previous Request | Optimized Request |
| :--- | :--- | :--- | :--- | :--- |
| CPU | 1000m | 500m | 200m | 200m |
| Memory | 1.5Gi | 1Gi | 256Mi | 512Mi |

*Note: Memory requests were standardized to 512Mi (aligned with ArgoCD core services) to ensure stability while significantly reducing the overall limit footprint.*

### 3. ArgoCD Platform
**File:** `cloud/terraform/gcp/gitops/platform/argocd.tf`

Verified that core services are using the standardized "reduced" values:
- **CPU Request:** 250m
- **Memory Request:** 512Mi

Core services include:
- ArgoCD ApplicationSet Controller
- ArgoCD Controller
- ArgoCD Repo Server
- ArgoCD Server

## Total Impact

| Metric | Total Reduction (Requests) | Total Reduction (Limits) |
| :--- | :--- | :--- |
| **CPU** | **1500m** | **1500m** |
| **Memory** | **-256Mi** (Standardized) | **2.0Gi** |

*Note: While memory requests for Crossplane providers were slightly increased to 512Mi for consistency and reliability, the overall memory limit footprint was reduced by over 2Gi.*
