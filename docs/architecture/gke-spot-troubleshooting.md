# GKE Autopilot Spot Scheduling: Troubleshooting Log

## Executive Summary
This document tracks the iterative attempts to resolve scheduling deadlocks when using **GKE Spot Nodes** in an Autopilot cluster. Despite multiple policy adjustments and quota increases, certain platform pods (ArgoCD) remained in a `Pending` state with `GCE quota exceeded` errors.

---

## 1. Timeline of Attempts

### Attempt 1: "Required" Spot Affinity (Initial State)
*   **Strategy**: Kyverno injected a `requiredDuringSchedulingIgnoredDuringExecution` affinity for `gke-spot=true` into all non-system pods.
*   **Result**: **FAILURE.** Pods were stuck in `Pending`. Cluster autoscaler reported "Unhelpable" because it could not fulfill the Spot request due to 0 quota, and the pods were forbidden from running on standard nodes.

### Attempt 2: "Preferred" Spot Affinity + Standard Fallback
*   **Strategy**: Changed Kyverno to use `preferredDuringSchedulingIgnoredDuringExecution` (Weight 100). Added a second preference for Standard nodes (Weight 10).
*   **Result**: **PARTIAL SUCCESS.** Some pods started, but others (like `dex-server`) remained stuck. Descibing the pods revealed that Kyverno was still injecting a **forced toleration** for `gke-spot:NoSchedule`.

### Attempt 3: Removing Forced Tolerations
*   **Strategy**: Removed the `tolerations` block from the Kyverno policy.
*   **Result**: **FAILURE.** Even with no toleration and "Preferred" affinity, the GKE scheduler prioritized the Spot request. Since the project had reached its Spot limit, the autoscaler kept trying (and failing) to create Spot nodes instead of instantly falling back to Standard capacity.

### Attempt 4: Strict Namespace Exclusion
*   **Strategy**: Excluded the `argocd` namespace from the Kyverno policy entirely at the rule level.
*   **Result**: **STILL PENDING.** Some pods picked up the change, but "Ghost" tolerations persisted on `ReplicaSet`-managed pods, likely due to Kyverno mutation cache or existing controller state.

---

## 2. Lessons Learned
1.  **Autopilot "Sticky" Logic**: GKE Autopilot's scheduler is highly aggressive about fulfilling "Preferred" Spot requests if a pod has any labels hinting at Spot usage.
2.  **Toleration Trap**: Any pod with a `gke-spot` toleration **cannot** run on a standard node unless that standard node also has a matching taint (which they don't). The toleration is a "Hard Requirement" for the node type, regardless of affinity.
3.  **Quota propagation**: GCE quota increases can take 15-30 minutes to be fully recognized by the regional cluster autoscaler.

---

## 3. New Ideas & Future Approaches

### Idea A: Standard-Only Platform Namespace (The "Safe" Approach)
Instead of forcing "Prefer Spot" on the whole cluster, we should explicitly label namespaces like `argocd` and `infra` with a "Standard Only" requirement. 
*   **Action**: Use a Kyverno policy to *forbid* Spot usage in these namespaces to ensure platform stability.

### Idea B: Two-Tiered Kyverno
Split the policy into two distinct rules:
1.  **Rule 1**: For "System/Platform" namespaces -> Inject `required` Standard affinity.
2.  **Rule 2**: For "Application" namespaces -> Inject `preferred` Spot affinity.

### Idea C: Explicit Node Selector
In GKE Autopilot, the most reliable way to force a specific node type is the `nodeSelector`.
*   **Action**: Update the ArgoCD Helm chart values to explicitly set `nodeSelector: { cloud.google.com/gke-spot: "false" }` for the `server` and `controller` components.

### Idea D: Hard Resource Quotas
Set a `ResourceQuota` on the `argocd` namespace that is slightly *higher* than the total requests. This forces Autopilot to look for specific "slots" on existing standard nodes rather than trying to spin up new (unavailable) Spot nodes.
