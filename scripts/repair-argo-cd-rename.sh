#!/bin/bash
# repair-argo-cd-rename.sh
# Fixes ownership conflicts and stuck namespaces after renaming ArgoCD to Argo_CD.

echo "Step 1: Clearing Helm ownership annotations from ArgoCD CRDs..."
CRDS=(
  "applications.argoproj.io"
  "applicationsets.argoproj.io"
  "appprojects.argoproj.io"
)

for crd in "${CRDS[@]}"; do
  if kubectl get crd "$crd" &>/dev/null; then
    echo "Patching $crd..."
    kubectl annotate crd "$crd" meta.helm.sh/release-name- meta.helm.sh/release-namespace- --overwrite
    kubectl label crd "$crd" app.kubernetes.io/managed-by- --overwrite
  else
    echo "CRD $crd does not exist, skipping."
  fi
done

echo "Step 2: Checking for stuck 'argocd' namespace..."
if kubectl get ns argocd &>/dev/null; then
  echo "Namespace 'argocd' found. Attempting to clear finalizers from ArgoCD resources..."
  # Clear finalizers from Apps and Projects in the old namespace
  kubectl get application -n argocd -o name | xargs -I{} kubectl patch {} -n argocd --type=merge -p '{"metadata":{"finalizers":null}}'
  kubectl get appproject -n argocd -o name | xargs -I{} kubectl patch {} -n argocd --type=merge -p '{"metadata":{"finalizers":null}}'
  
  echo "Forcing namespace deletion if still stuck..."
  kubectl delete ns argocd --wait=false
fi

echo "Step 3: Ready for Terraform!"
echo "You can now run: ./submit_build.sh <PROJECT_ID> --step=platform"
