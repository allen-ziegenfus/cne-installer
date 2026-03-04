# GitHub App Setup

If you'd like to use a GitHub App for SSO / GitHub repo access, you can use the [GitHub App Manifest Tool](github-app-generator.html ":ignore").

### Why use a GitHub App?
Using a GitHub App is the recommended way to handle authentication for:
- **ArgoCD SSO**: Allowing your team to log in using their GitHub credentials.
- **GitOps Repository Access**: Securely pulling Helm charts and manifests without using personal access tokens.

### Setup Steps:

1. **Generate Manifest**: Use the [GitHub App Manifest Tool](github-app-generator.html ":ignore"). Enter your **GitHub Organization** and **ArgoCD Base URL** (e.g., `https://argocd.example.com`).
2. **Register**: Click **Register GitHub App**. You will be redirected to GitHub to name and create the app.
3. **Install**: After creation, navigate to **Install App** in the GitHub App settings and install it on your organization.
4. **Retrieve Credentials**: Upon installation, you will be redirected to a success page containing a `code`. 
5. **Finalize**: Use the `curl` command provided by the tool (using your `code`) to retrieve your **App ID** and **Private Key**.
6. **Store Secrets**: Run the following command in your Cloud Shell to securely store these credentials in GCP Secret Manager:
   ```bash
   ./setup-github-app-secret.sh <PROJECT_ID>
   ```
