# Kubernetes Gateway Implementation Comparison

## Executive Summary
This report compares the Google Cloud Platform (GCP) implementation of the Kubernetes Gateway API (using Envoy Gateway) with the standard established by the AWS Team in the `portal/` directory.

## 1. Technical Comparison

| Feature | GCP Implementation (Local) | AWS Team Implementation (`portal/`) |
| :--- | :--- | :--- |
| **Orchestration** | **Subchart Pattern:** Local `gateway-infra` chart wrapping `envoyproxy/gateway-helm`. | **Native OCI Pattern:** Direct `helm_release` from `oci://docker.io/envoyproxy`. |
| **CRD Management** | **Explicit:** Separate `gateway-crds` Helm chart in Terraform. | **Managed:** Handled via specific controller bootstrap or lifecycle. |
| **Traffic Policy** | **Minimal:** Standard `HTTPRoute` and `EnvoyProxy` (ClusterIP). | **Advanced:** Uses `ClientTrafficPolicy` for `ProxyProtocol` (Real IP support). |
| **Networking** | **Internal-First:** Optimized for `ClusterIP`/Internal routing. | **Public-Facing:** Optimized for NLB/ELB integration with `ProxyProtocol`. |
| **Versioning** | **Local Wrapper:** Versioned via local chart (`1.0.3`). | **Pinned Upstream:** Versioned via `helm_release` (`v1.6.3`). |
| **GitOps** | **Standard:** No specific sync-wave orchestration. | **Orchestrated:** Uses `argocd.argoproj.io/sync-wave: "-30"`. |

## 2. Key Differences & Observations

### 2.1 Orchestration Patterns
The GCP implementation uses a "Wrapper Chart" approach. This provides more control over the subchart's values but adds a layer of maintenance (bumping local versions vs. upstream versions). The AWS team prefers the "Direct OCI" approach, which is more idiomatic for modern Terraform/Helm deployments.

### 2.2 Production Readiness (Real IP)
The AWS implementation explicitly handles the "Real IP" problem using a `ClientTrafficPolicy` to enable `ProxyProtocol`. The GCP implementation currently lacks an equivalent policy for GCP-specific Load Balancer integration (e.g., `GCPGatewayPolicy`).

### 2.3 Platform Constraints & CRD Management
A critical divergence exists due to the underlying managed Kubernetes platforms:

*   **GCP (Autopilot):** GKE Autopilot has a hardened admission controller that restricts the installation of certain "experimental" or "alpha" CustomResourceDefinitions (CRDs). The official Envoy Gateway OCI chart often fails on Autopilot because it attempts to install these restricted CRDs directly. The GCP implementation uses a **Manual/Decoupled CRD pattern** to allow for surgical control over which CRDs are applied and to bypass Autopilot's strict automated blocks.
*   **AWS (EKS):** AWS EKS (standard or Fargate) is significantly more permissive. It allows for the direct installation of any valid Kubernetes CRD, including the full Envoy Gateway suite. This allows the AWS team to use the **Native OCI Pattern** without manual intervention or separate CRD management.

### 2.4 GitOps Reliability
The AWS team uses ArgoCD `sync-waves` (`-30`) on their Gateway resources. This ensures that the Gateway infrastructure is fully reconciled by the Envoy Gateway controller *before* application-level `HTTPRoutes` or `LiferayInfrastructure` resources are processed, preventing race conditions during cluster bootstrapping.

## 3. Recommendations for GCP Harmonization
1.  **Adopt Sync-Waves:** Add `argocd.argoproj.io/sync-wave: "-30"` to the `Gateway` and `EnvoyProxy` resources in the `gateway-infra` chart.
2.  **Evaluate OCI Pattern:** Consider moving from a local subchart to a direct OCI `helm_release` in Terraform to reduce version-bump overhead.
3.  **GCP Policy Integration:** If using external GCP Load Balancing, implement `GCPGatewayPolicy` to handle health checks and SSL termination similar to the AWS `ClientTrafficPolicy`.
