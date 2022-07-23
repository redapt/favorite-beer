AWS_REGION="us-east-2"
J8S_EKS_CLUSTER="test-rg-aws"
J8S_EKS_CLUSTER_KUBECTL_ROLE="rg-test-kubectl-access-role"
J8S_SA_NAME="jenkins-sa-agent"
J8S_NAMESPACE="jenkins"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)

J8S_JENKINS_AGENT_REPOSITORY_NAME="jenkins-inbound-agent"
SOURCE_J8S_JENKINS_AGENT_REPOSITORY="docker.io/jenkins/inbound-agent"
SOURCE_J8S_JENKINS_AGENT_TAG="4.3-4-alpine"

J8S_ARGO_TOOLS_REPOSITORY_NAME="argo-cd-ci-builder"
SOURCE_J8S_ARGO_TOOLS_REPOSITORY="docker.io/argoproj/argo-cd-ci-builder"
SOURCE_J8S_ARGO_TOOLS_TAG="v1.0.0"

J8S_KANIKO_REPOSITORY_NAME="kaniko"
SOURCE_J8S_KANIKO_REPOSITORY="gcr.io/kaniko-project/executor"
SOURCE_J8S_KANIKO_TAG="debug"

J8S_PODMAN_REPOSITORY_NAME="podman-aws"
SOURCE_J8S_ALPINE_REPOSITORY="alpine"
SOURCE_J8S_ALPINE_TAG="latest"
SOURCE_J8S_PODMAN_AWS_TAG="latest" # Arbitrary, this is a custom flavor.

ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "If the script ends shortly after this message, you are missing a dependency, please check the script for more details."

aws eks update-kubeconfig --name $J8S_EKS_CLUSTER --region $AWS_REGION --role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/$J8S_EKS_CLUSTER_KUBECTL_ROLE || exit
helm version || exit
eksctl version || exit
kubectl version || exit

helm repo add jenkins https://charts.jenkins.io && helm repo update &>/dev/null

helm upgrade --install jenkins jenkins/jenkins \
  --namespace $J8S_NAMESPACE \
  --create-namespace \
  --set rbac.create=true \
  --set controller.servicePort=80 \
  --set controller.serviceType=LoadBalancer \
  --set controller.resources.requests.cpu=1000m \
  --set controller.resources.requests.memory=1024Mi

## Need to install github-branch-source plugin 1656.v77eddb_b_e95df 

## Need to configure the server url, based on the service, for better github updates.

# Can only create the role here, since eksctl does not pass the assumed role from local context.
eksctl create iamserviceaccount \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser \
    --cluster $J8S_EKS_CLUSTER \
    --name $J8S_SA_NAME \
    --namespace $J8S_NAMESPACE \
    --override-existing-serviceaccounts \
    --region $AWS_REGION \
    --approve \
    --role-only || true

export EKS_ECR_ROLE_ID=$(aws cloudformation describe-stacks --stack-name eksctl-$J8S_EKS_CLUSTER-addon-iamserviceaccount-$J8S_NAMESPACE-$J8S_SA_NAME --region $AWS_REGION --query "Stacks[0].Outputs[0].OutputValue" --output text)

kubectl create serviceaccount $J8S_SA_NAME -n $J8S_NAMESPACE || true

kubectl patch serviceaccount $J8S_SA_NAME -n $J8S_NAMESPACE --patch '{"metadata": {"annotations": {"eks.amazonaws.com/role-arn":"'$EKS_ECR_ROLE_ID'"}}}'



############################################################################
# Jenkins JNLP Agent
############################################################################

J8S_JENKINS_AGENT_REPOSITORY=$(aws ecr describe-repositories --repository-names "${J8S_JENKINS_AGENT_REPOSITORY_NAME}" --query "repositories[0].repositoryUri" --output text 2>/dev/null || \
           aws ecr create-repository --repository-name "${J8S_JENKINS_AGENT_REPOSITORY_NAME}"  --query "repository.repositoryUri" --output text)
docker pull $SOURCE_J8S_JENKINS_AGENT_REPOSITORY:$SOURCE_J8S_JENKINS_AGENT_TAG
docker tag $SOURCE_J8S_JENKINS_AGENT_REPOSITORY:$SOURCE_J8S_JENKINS_AGENT_TAG $J8S_JENKINS_AGENT_REPOSITORY:$SOURCE_J8S_JENKINS_AGENT_TAG
aws ecr get-login-password \
  --region $AWS_REGION | \
  docker login \
    --username AWS \
    --password-stdin $J8S_JENKINS_AGENT_REPOSITORY
docker push $J8S_JENKINS_AGENT_REPOSITORY:$SOURCE_J8S_JENKINS_AGENT_TAG

############################################################################
# ARGO CD CI Tools
############################################################################

J8S_ARGO_TOOLS_REPOSITORY=$(aws ecr describe-repositories --repository-names "${J8S_ARGO_TOOLS_REPOSITORY_NAME}" --query "repositories[0].repositoryUri" --output text 2>/dev/null || \
           aws ecr create-repository --repository-name "${J8S_ARGO_TOOLS_REPOSITORY_NAME}"  --query "repository.repositoryUri" --output text)
docker pull $SOURCE_J8S_ARGO_TOOLS_REPOSITORY:$SOURCE_J8S_ARGO_TOOLS_TAG
docker tag $SOURCE_J8S_ARGO_TOOLS_REPOSITORY:$SOURCE_J8S_ARGO_TOOLS_TAG $J8S_ARGO_TOOLS_REPOSITORY:$SOURCE_J8S_ARGO_TOOLS_TAG
aws ecr get-login-password \
  --region $AWS_REGION | \
  docker login \
    --username AWS \
    --password-stdin $J8S_ARGO_TOOLS_REPOSITORY
docker push $J8S_ARGO_TOOLS_REPOSITORY:$SOURCE_J8S_ARGO_TOOLS_TAG

############################################################################
# Kaniko Image Builder for AWS Instance Profiles
############################################################################

J8S_KANIKO_REPOSITORY=$(aws ecr describe-repositories --repository-names "${J8S_KANIKO_REPOSITORY_NAME}" --query "repositories[0].repositoryUri" --output text 2>/dev/null || \
           aws ecr create-repository --repository-name "${J8S_KANIKO_REPOSITORY_NAME}"  --query "repository.repositoryUri" --output text)
mkdir -p agent/kaniko
cd agent/kaniko
cat > Dockerfile<<EOF
FROM $SOURCE_J8S_KANIKO_REPOSITORY:$SOURCE_J8S_KANIKO_TAG
COPY ./config.json /kaniko/.docker/config.json
EOF
cat > config.json<<EOF
{ "credsStore": "ecr-login" }
EOF
docker build -t $J8S_KANIKO_REPOSITORY:$SOURCE_J8S_KANIKO_TAG .
aws ecr get-login-password \
  --region $AWS_REGION | \
  docker login \
    --username AWS \
    --password-stdin $J8S_KANIKO_REPOSITORY
docker push $J8S_KANIKO_REPOSITORY:$SOURCE_J8S_KANIKO_TAG

############################################################################
# Podman for AWS Instance Profiles
############################################################################

J8S_PODMAN_REPOSITORY=$(aws ecr describe-repositories --repository-names "${J8S_PODMAN_REPOSITORY_NAME}" --query "repositories[0].repositoryUri" --output text 2>/dev/null || \
           aws ecr create-repository --repository-name "${J8S_PODMAN_REPOSITORY_NAME}"  --query "repository.repositoryUri" --output text)
mkdir -p ../agent/podman-aws
cd ../agent/podman-aws
cat > Dockerfile<<EOF
FROM $SOURCE_J8S_ALPINE_REPOSITORY:$SOURCE_J8S_ALPINE_TAG
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/community podman
RUN apk add --no-cache \
    python3 \
    py3-pip \
    && pip3 install --upgrade pip \
    && pip3 install --no-cache-dir \
    awscli \
    && rm -rf /var/cache/apk/*
ENV STORAGE_DRIVER=vfs
EOF
docker build -t $J8S_PODMAN_REPOSITORY:$SOURCE_J8S_PODMAN_AWS_TAG .
aws ecr get-login-password \
  --region $AWS_REGION | \
  docker login \
    --username AWS \
    --password-stdin $J8S_PODMAN_REPOSITORY
docker push $J8S_PODMAN_REPOSITORY:$SOURCE_J8S_PODMAN_AWS_TAG




