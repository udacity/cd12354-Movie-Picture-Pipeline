#!/bin/bash
set -e -o pipefail

echo "Fetching IAM github-action-user ARN"
userarn=$(aws iam get-user --user-name github-action-user | jq -r .User.Arn)
echo $userarn

# Define the version of aws-iam-authenticator
IAM_AUTHENTICATOR_VERSION="0.6.3"
IAM_AUTHENTICATOR_URL="https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v${IAM_AUTHENTICATOR_VERSION}/aws-iam-authenticator_${IAM_AUTHENTICATOR_VERSION}_linux_amd64"

# Download and install aws-iam-authenticator
echo "Downloading aws-iam-authenticator..."
curl -L "$IAM_AUTHENTICATOR_URL" -o aws-iam-authenticator
chmod +x aws-iam-authenticator

# Update permissions
echo "Updating permissions..."
# ./aws-iam-authenticator add user --userarn="${userarn}" --username=github-action-role --groups=system:masters --kubeconfig="$HOME"/.kube/config --prompt=false
kubectl config set-credentials github-action-role --exec-command=aws-iam-authenticator --exec-api-version=client.authentication.k8s.io/v1alpha1 --exec-arg="token" --exec-arg="-i" --exec-arg="cluster"

# Clean up
echo "Cleaning up..."
rm aws-iam-authenticator

echo "Done!"
