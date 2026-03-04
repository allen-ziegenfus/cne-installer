#!/bin/bash
# repair-argocd-rename.sh
# Fixes ownership conflicts and stuck namespaces/resources after renaming ArgoCD.

echo "Step 1: Patching ArgoCD CRDs with NEW ownership (argocd)..."
CRDS=(
  "applications.argoproj.io"
  "applicationsets.argoproj.io"
  "appprojects.argoproj.io"
)

for crd in "${CRDS[@]}"; do
  if kubectl get crd "$crd" &>/dev/null; then
    echo "Adopting $crd..."
    kubectl annotate crd "$crd" meta.helm.sh/release-name="argocd" --overwrite
    kubectl annotate crd "$crd" meta.helm.sh/release-namespace="argocd" --overwrite
    kubectl label crd "$crd" app.kubernetes.io/managed-by="Helm" --overwrite
  else
    echo "CRD $crd does not exist, skipping."
  fi
done

echo "Step 2: Clearing stuck ApplicationSets and Applications..."
# This removes finalizers from ALL ArgoCD resources to allow Terraform/Helm to delete them immediately
RESOURCES=(
  "applicationsets.argoproj.io"
  "applications.argoproj.io"
  "appprojects.argoproj.io"
)

for res in "${RESOURCES[@]}"; do
  echo "Stripping finalizers from $res..."
  kubectl get "$res" --all-namespaces -o name | xargs -I{} kubectl patch {} --all-namespaces --type=merge -p '{"metadata":{"finalizers":null}}' 2>/dev/null
done

echo "Step 3: Cleaning up stuck 'argocd' or 'argo-cd' namespaces..."
for ns in "argocd" "argo-cd"; do
  if kubectl get ns "$ns" &>/dev/null; then
    echo "Namespace '$ns' found. Forcing cleanup..."
    kubectl delete ns "$ns" --wait=false
    
    # Use the "finalize" trick if still present
    sleep 2
    if kubectl get ns "$ns" &>/dev/null; then
      echo "Namespace $ns still stuck. Using force-finalize trick..."
      kubectl get namespace "$ns" -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/$ns/finalize" -f -
    fi
  fi
done

echo "Step 4: Ready for Terraform!"
echo "You can now run your terraform destroy or apply again."
