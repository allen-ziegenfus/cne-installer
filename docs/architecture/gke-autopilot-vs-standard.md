# GKE Autopilot vs. Standard: Observations

## Executive Summary
This report documents the operational challenges and cost considerations discovered during the POC phase while using GKE Autopilot compared to GKE Standard. While Autopilot aligns better with the AWS "managed" philosophy, it introduces unique complexities around Spot node forcing and cost management.

## 1. The Two "Flavors" of GKE

| Feature | GKE Standard | GKE Autopilot |
| :--- | :--- | :--- |
| **Pricing Model** | Pay-per-node (VM resources). | Pay-per-pod (Requested resources). |
| **Control Surface** | Direct node pool management. | Label-driven pod configuration. |
| **Spot Strategy** | **Explicit:** Taint/Tolerate node pools. | **Implicit:** Injected via pod labels. |
| **Complexity** | Higher (Node lifecycle management). | Lower (Hands-off infrastructure). |

## 2. Key Observations & Challenges

### 2.1 Spot Node "Hard-Forcing"
In **GKE Standard**, forcing 100% Spot usage is straightforward: you simply create ONLY Spot-backed node pools. If quota is unavailable, the cluster just doesn't scale, but you have absolute cost certainty.

In **GKE Autopilot**, you cannot "force" the cluster to only use Spot at the infrastructure level. You must influence it through pod labels/annotations. As discovered in this POC:
-   **Scheduling Blocks**: If you use a "Required" affinity for Spot nodes and the GCE quota is reached, pods enter a `Pending` state that the cluster autoscaler cannot resolve ("Unhelpable").
-   **Fallback Requirement**: To ensure platform stability (e.g., ArgoCD), a "Preferred" affinity with a standard node fallback is required, which compromises the "Spot-only" cost goal.

### 2.2 Cost Management Risks
Autopilot shifts the responsibility of cost optimization from the Infrastructure Engineer to the Developer:
-   **Label Dependency**: If a developer forgets to add the correct Spot labels, GKE provisions standard (expensive) capacity by default.
-   **Provisioning Limits**: By default, there are no hard restrictions on how much can be provisioned. A misconfigured `ApplicationSet` could theoretically spin up hundreds of expensive standard pods instantly.

## 3. Alternative Approaches

### 3.1 Kyverno Policy Enforcement (Current Approach)
We are currently using Kyverno to automatically inject the correct labels into all pods. This centralizes the "infra task" but still requires the "Preferred" fallback to prevent scheduling deadlocks during quota shortages.

### 3.2 Resource Quotas
To mitigate the risk of runaway costs in Autopilot, we should implement **Kubernetes ResourceQuotas** at the namespace level. This sets a "hard ceiling" on how much total CPU/Memory a team can request, regardless of whether they use Spot or Standard nodes.

### 3.3 GKE Standard "Cost-Optimized"
If absolute cost control and "Spot-only" enforcement are the highest priorities, GKE Standard remains the superior choice. It allows for rigid node-pool definitions that simply cannot provision standard capacity unless an administrator manually creates a new pool.

## 4. Conclusion
While GKE Autopilot provides convenience and better alignment with managed AWS services, it requires a robust **Policy-Driven** approach (Kyverno + ResourceQuotas) to match the cost-predictability of GKE Standard.
