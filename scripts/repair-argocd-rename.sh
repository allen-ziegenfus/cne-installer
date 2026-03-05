#!/bin/bash
# repair-argocd-rename.sh
# Fixes ownership conflicts and stuck namespaces/resources after renaming ArgoCD.

function main {
    echo "Step 1: Patching ArgoCD CRDs with NEW ownership (argocd)."
    local crds=(
      "applications.argoproj.io"
      "applicationsets.argoproj.io"
      "appprojects.argoproj.io"
    )

    for crd in "${crds[@]}"; do
      if kubectl get crd "${crd}" &>/dev/null; then
        echo "Adopting ${crd}."
        kubectl annotate crd "${crd}" meta.helm.sh/release-name="argocd" --overwrite
        kubectl annotate crd "${crd}" meta.helm.sh/release-namespace="argocd" --overwrite
        kubectl label crd "${crd}" app.kubernetes.io/managed-by="Helm" --overwrite
      else
        echo "CRD ${crd} does not exist, skipping."
      fi
    done

    echo "Step 2: Adopting existing Kyverno \"prefer-spot-nodes\" ClusterPolicy."
    if kubectl get clusterpolicy prefer-spot-nodes &>/dev/null; then
        echo "Found existing prefer-spot-nodes policy. Patching for Helm adoption."
        kubectl annotate clusterpolicy prefer-spot-nodes meta.helm.sh/release-name="kyverno-policies" --overwrite
        kubectl annotate clusterpolicy prefer-spot-nodes meta.helm.sh/release-namespace="kyverno" --overwrite
        kubectl label clusterpolicy prefer-spot-nodes app.kubernetes.io/managed-by="Helm" --overwrite
    else
        echo "ClusterPolicy prefer-spot-nodes not found, skipping."
    fi

    echo "Step 3: Clearing stuck ApplicationSets and Applications."
    local resources=(
      "applicationsets.argoproj.io"
      "applications.argoproj.io"
      "appprojects.argoproj.io"
    )

    for res in "${resources[@]}"; do
      echo "Stripping finalizers from ${res}."
      kubectl get "${res}" --all-namespaces -o name | xargs -I{} kubectl patch {} --all-namespaces --type=merge -p '{"metadata":{"finalizers":null}}' 2>/dev/null
    done

    echo "Step 4: Cleaning up stuck \"argocd\" or \"argo-cd\" namespaces."
    for ns in "argocd" "argo-cd"; do
      if kubectl get ns "${ns}" &>/dev/null; then
        echo "Namespace \"${ns}\" found. Forcing cleanup."
        kubectl delete ns "${ns}" --wait=false
        
        # Use the "finalize" trick if still present
        sleep 2
        if kubectl get ns "${ns}" &>/dev/null; then
          echo "Namespace ${ns} still stuck. Using force-finalize trick."
          local ns_json
          ns_json=$(kubectl get namespace "${ns}" -o json | jq '.spec.finalizers = []')
          echo "${ns_json}" | kubectl replace --raw "/api/v1/namespaces/${ns}/finalize" -f -
        fi
      fi
    done

    echo "Step 5: Ready for Terraform."
    echo "You can now run: ./submit_build.sh <PROJECT_ID> --step=kyverno"
}

main "${@}"
