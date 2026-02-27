#!/bin/bash -x

# GKE Gateway does not allow the experimental Gateway CRDs and this helm chart does not allow any way
# to just deploy the envoy specific CRDs, so we just copy directly from the chart

pushd ../gateway-infra
helm dependency update
TEMPDIR=$(mktemp -d)
tar xvzf charts/*.tgz  -C $TEMPDIR
popd
rm -rf crds/generated
mkdir -p crds/generated
mv ${TEMPDIR}/gateway-helm/crds/generated/* crds/generated
rm -rf ${TEMPDIR}