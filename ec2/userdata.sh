#!/bin/bash

# Update system and install AWS CLI v2
yum update -y || apt-get update -y
if ! command -v aws >/dev/null 2>&1; then
  if command -v yum >/dev/null 2>&1; then
    yum install -y unzip curl wget git bash-completion || true
  else
    apt-get install -y unzip curl wget git bash-completion || true
  fi
  TMPDIR=/tmp/awscli
  mkdir -p $TMPDIR
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
  unzip -o /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install -i /usr/local/aws-cli -b /usr/local/bin || true
fi

# Install Docker
if command -v dnf >/dev/null 2>&1; then
 dnf -y install docker
elif command -v apt-get >/dev/null 2>&1; then
  apt-get install -y docker.io
fi
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user || true

# Install Jenkins + Java
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf upgrade -y
# Add required dependencies for the jenkins package
sudo dnf install fontconfig java-17-amazon-corretto-devel -y
sudo dnf install jenkins -y
sudo systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins || true

# Update Git
yum update -y git || apt-get install -y git

# Install kubectl (latest)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo 'source <(kubectl completion bash)' >> /etc/bashrc

# Install Terraform (latest)
if command -v yum >/dev/null 2>&1; then
  yum install -y yum-utils
  yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
  yum -y install terraform
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update && apt-get install -y gnupg software-properties-common
  wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | tee /etc/apt/sources.list.d/hashicorp.list
  apt-get update && apt-get install -y terraform
fi