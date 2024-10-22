set -eEuo pipefail
set -x
gcloud config set project $1
{ set +x; } 2>/dev/null
echo "🚀 finding and replacing project-id in terraform code..."
find associate/lab_01/iac -type f -name "provider.tf" -exec sed -i "s/project =.*/project = \"$1\"/g" {} +
find associate/lab_01/iac -type f -name "provider.tf" -exec sed -i "s/project_id =.*/project_id = \"$1\"/g" {} +
