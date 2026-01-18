#!/bin/bash

# Senior DevOps Interactive Setup Script
# Orchestrates Terraform (with WIF), GKE, and Flux CD.

set -e

echo "🚀 Welcome to the Senior DevOps Stack Auto-Setup!"
echo "--------------------------------------------------"

# Function to prompt for variables
prompt_var() {
    local var_name=$1
    local prompt_text=$2
    local default_val=$3
    local current_val=${!var_name}

    if [ -z "$current_val" ]; then
        read -p "$prompt_text [$default_val]: " input
        input=${input:-$default_val}
        export $var_name="$input"
    else
        echo "Using existing $var_name: ${!var_name}"
    fi
}

# 1. Gather Information
echo "TIP: For Qwiklabs, check the lab instructions for the allowed region (e.g., us-east1, us-east4, us-west1)."
prompt_var "GCP_PROJECT_ID" "Enter your GCP Project ID" "my-project-id"
prompt_var "GCP_REGION" "Enter GCP Region" "us-east1"
prompt_var "GITHUB_USER" "Enter your GitHub Username" "my-user"
prompt_var "GITHUB_REPO_NAME" "Enter your GitHub Repository Name" "proyecto_entrevista"
prompt_var "GITHUB_TOKEN" "Enter your GitHub Personal Access Token (Repo scope)" ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ GITHUB_TOKEN is required. Please generate one at https://github.com/settings/tokens"
    exit 1
fi

GITHUB_REPO_FULL="$GITHUB_USER/$GITHUB_REPO_NAME"

# 2. Infrastructure with Terraform
echo ""
echo "🏗️  Provisioning Infrastructure with Terraform (including WIF)..."
cd terraform
terraform init
terraform apply \
  -var="project_id=$GCP_PROJECT_ID" \
  -var="region=$GCP_REGION" \
  -var="github_repo=$GITHUB_REPO_FULL" \
  -auto-approve

WIF_PROVIDER=$(terraform output -raw wif_provider_name)
GSA_EMAIL=$(terraform output -raw github_actions_sa_email)
cd ..

# 3. Configure Kubectl
echo ""
echo "☸️  Configuring kubectl for GKE..."
gcloud container clusters get-credentials "senior-devops-cluster" --region "$GCP_REGION" --project "$GCP_PROJECT_ID"

# 4. Flux CD Bootstrap
echo ""
echo "🌊 Bootstrapping Flux CD via GitOps..."


# Dynamic Manifest Update
# Replaces the URL in the GitRepository manifest with the user's repo.
echo "🔧 Configuring Flux GitRepository URL..."
FLUX_MANIFEST="./k8s/clusters/production/nginx-app.yaml"
# Ensure we point to the correct repo
sed -i "s|url: .*|url: https://github.com/${GITHUB_REPO_FULL}.git|g" "$FLUX_MANIFEST"
# Rename 'podinfo' to 'project-repo' for clarity
sed -i "s|name: podinfo|name: project-repo|g" "$FLUX_MANIFEST"

echo "💾 Committing manifest changes to Git..."
git add "$FLUX_MANIFEST"
# We commit only if there are changes to avoid empty commit errors
git diff-index --quiet HEAD || git commit -m "Configure Flux GitRepository URL for ${GITHUB_REPO_FULL}"
git push origin main || echo "⚠️ Could not push to main. If using a personal repo, ensure you have permissions."



flux bootstrap github \
  --owner="$GITHUB_USER" \
  --repository="$GITHUB_REPO_NAME" \
  --branch=main \
  --path=./k8s/clusters/production \
  --personal

echo ""
echo "--------------------------------------------------"
echo "✅ Setup Complete!"
echo ""
echo "CRITICAL: Add these secrets to your GitHub Repository ($GITHUB_REPO_FULL):"
echo "- GCP_PROJECT_ID: $GCP_PROJECT_ID"
echo "- WIF_PROVIDER: $WIF_PROVIDER"
echo "- WIF_SERVICE_ACCOUNT: $GSA_EMAIL"
echo "--------------------------------------------------"
echo "Check Flux status: flux get kustomizations"
