gcloud config set project $1

gcloud builds submit . \
    --config=cloudbuild.yaml \
    --substitutions=_REGION="$TF_VAR_region",_REPO_URL="$(git config --get remote.origin.url)",_STATE_BUCKET="$STATE_BUCKET"