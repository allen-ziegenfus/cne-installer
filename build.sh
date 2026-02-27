gcloud builds submit . \
    --config=cloudbuild.yaml \
    --substitutions=_REGION="$TF_VAR_region",_REPO_URL="https://github.com/your-repo",_STATE_BUCKET="$STATE_BUCKET"