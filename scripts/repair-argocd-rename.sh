#!/bin/bash
# repair-argocd-rename.sh
# Fixes ownership conflicts and stuck namespaces after renaming ArgoCD.

echo "Step 1: Patching ArgoCD CRDs with NEW ownership (argo-cd)..."
CRDS=(
  "applications.argoproj.io"
  "applicationsets.argoproj.io"
  "appprojects.argoproj.io"
)

for crd in "${CRDS[@]}"; do
  if kubectl get crd "$crd" &>/dev/null; then
    echo "Adopting $crd..."
    kubectl annotate crd "$crd" meta.helm.sh/release-name="argo-cd" --overwrite
    kubectl annotate crd "$crd" meta.helm.sh/release-namespace="argo-cd" --overwrite
    kubectl label crd "$crd" app.kubernetes.io/managed-by="Helm" --overwrite
  else
    echo "CRD $crd does not exist, skipping."
  fi
done

echo "Step 2: Cleaning up stuck 'argocd' namespace..."
if kubectl get ns argocd &>/dev/null; then
  echo "Namespace 'argocd' found. Force-clearing finalizers..."
  
  # Delete all apps and projects in the old namespace and strip finalizers
  kubectl get application -n argocd -o name | xargs -I{} kubectl patch {} -n argocd --type=merge -p '{"metadata":{"finalizers":null}}'
  kubectl get appproject -n argocd -o name | xargs -I{} kubectl patch {} -n argocd --type=merge -p '{"metadata":{"finalizers":null}}'
  
  # Final attempt to delete the namespace itself
  kubectl delete ns argocd --wait=false
  
  # If still stuck after 10 seconds, use the "finalize" trick
  sleep 5
  if kubectl get ns argocd &>/dev/null; then
    echo "Namespace still stuck. Using force-finalize trick..."
    kubectl get namespace argocd -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/argocd/finalize" -f -
  fi
fi

echo "Step 3: Ready for Terraform!"
echo "Run: ./submit_build.sh <PROJECT_ID> --step=platform"
