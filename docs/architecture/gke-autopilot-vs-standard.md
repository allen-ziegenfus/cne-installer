# GKE Autopilot vs. Standard: Operational Experience

## Executive Summary
This report documents the operational challenges and cost considerations discovered during the POC phase while using GKE Autopilot compared to GKE Standard. While GKE Autopilot is marketed as a "hands-free" SaaS-like experience, this investigation concludes that **GKE Standard is the superior choice for Liferay Cloud Native deployments**. 

GKE Standard provides **Simplicity through Transparency**, allowing for absolute cost certainty and the infrastructure flexibility required for our architectural roadmap (e.g., Envoy Gateway), whereas Autopilot introduces a "functional ceiling" and unpredictable "black box" behavior.

## 1. The Two "Flavors" of GKE

| Feature | GKE Standard | GKE Autopilot |
| :--- | :--- | :--- |
| **Pricing Model** | Pay-per-node (VM resources). | Pay-per-pod (Requested resources). |
| **Control Surface** | Direct node pool management. | Label-driven pod configuration. |
| **Spot Strategy** | **Explicit:** Taint/Tolerate node pools. | **Implicit:** Injected via pod labels. |
| **Operational Toil** | Moderate (Manual pool config). | Minimal (Hands-off infrastructure). |
| **Predictability** | **High:** Deterministic node lifecycle. | **Lower:** "Black box" scheduling. |
| **Complexity** | Simple through transparency. | Simple through abstraction. |
| **Technical Ceiling** | None (Owner of admission control). | High (Google-managed restrictions). |

## 2. Replicating Autopilot Benefits in Standard
Most of Autopilot's "benefits" are simply GKE Standard features enabled by default. We can achieve a similar "managed" posture in Standard without surrendering control:

*   **Secure by Default:** We enable `shielded_nodes`, `workload_identity`, and enforce the **Pod Security Admission (PSA)** "Restricted" profile at the namespace level.
*   **Zero Node Management:** By enabling **Node Auto-provisioning (NAP)**, Standard can create new node pools on the fly. However, for Liferay's predictable workload, we prefer explicit pools for better cost tracking.
*   **Managed Upgrades:** We use **Maintenance Windows** to automate upgrades while retaining the power to block them during critical release cycles.

## 3. Why Autopilot Scaling is Irrelevant for Liferay
A primary selling point of Autopilot is its ability to automatically provision "exotic" infrastructure (GPUs, specialized architectures) based on pod labels.
*   **Uniformity:** Liferay DXP and its supporting services (Search, Database, Cache) run on standard x86 compute. We do not require specialized hardware or AI-workload scaling.
*   **Predictability:** We already know our resource requirements. We do not need a "fancier" autoscaler to discover our needs; a standard Cluster Autoscaler fulfills 100% of Liferay's scaling requirements with higher reliability and lower cost.

## 4. Key Observations & Technical Hurdles

### 4.1 The "CRD Blockade" (The Technical Ceiling)
Autopilot's non-removable Admission Controller blocks certain "experimental" or "alpha" CRDs.
*   **Issue:** The official **Envoy Gateway** OCI chart is blocked by Autopilot.
*   **The Standard Advantage:** In Standard, we own the Admission Controller and can safely install the CRDs required for our modern Ingress/Gateway strategy.

### 4.2 Absolute Cost Certainty (The Financial Floor)
*   **Standard:** We define a fixed-size Spot node pool for Dev/UAT. If pods exceed the quota, they stay `Pending`. We have a **hard floor** on costs.
*   **Autopilot:** If a developer accidentally omits Spot labels or requests excessive resources, GKE provisions standard capacity and bills us immediately. Autopilot is an open-ended financial risk.

### 4.3 Inflexible Upgrade Cycles
In Autopilot, cluster and node upgrades happen automatically on Google's schedule.
*   **Non-Deterministic Rollouts:** While Standard allows engineers to decide *when* and *how* to upgrade nodes (often following a meticulous process to minimize impact), Autopilot upgrades "just happen."
*   **Operational Risk:** This can cause unexpected downtime or customer impact if the application is not perfectly resilient to sudden node rotations. For enterprise deployments, the ability to block or delay upgrades during critical business cycles is a foundational requirement that Autopilot removes.

### 4.4 Deterministic Troubleshooting
*   **Standard:** If a pod won't schedule, we inspect the explicit state of the node pool. The cause (quota, taints, resources) is always transparent.
*   **Autopilot:** Scheduling logic is a "Black Box." Troubleshooting often involves "tricking" the hidden scheduler using affinities, which increases cognitive load during outages.

## 5. Comparison with AWS & The "Golden Path"
While AWS EKS "Auto Mode" is attractive because EKS Standard lacks built-in node autoscaling, GKE Standard *already* includes a managed Cluster Autoscaler. The operational gap between "Standard" and "Auto" is much smaller on GCP, making the sacrifice of control in Autopilot unnecessary.

## 6. Conclusion
GKE Standard is the preferred "Golden Path." It aligns with the managed-services philosophy while providing the **determinism** and **transparency** required for enterprise Liferay deployments. We gain the operational benefits of a managed cluster without the price markup, the CRD restrictions, or the loss of cost control.
